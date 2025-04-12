# Databricks notebook source
# MAGIC %md
# MAGIC # 📄 Invoice Extraction with GPT-4 Vision on Databricks
# MAGIC
# MAGIC ## 🧠 Overview
# MAGIC This project demonstrates how to build an end-to-end invoice extraction pipeline using Databricks, GPT-4 Vision via OpenAI, and Delta Lake. It reads invoice images stored on Azure Data Lake (`abfss`), resizes and compresses them to stay within OpenAI API limits, sends them to a vision-enabled LLM endpoint, and stores the structured JSON output into a Silver Delta table.
# MAGIC
# MAGIC This is a perfect case study for Data Engineers working with unstructured data and GenAI integrations.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## 📁 Directory and Data
# MAGIC - **Input source:** `abfss://owshq-shadow-traffic@owshqblobstg.dfs.core.windows.net/invoices/*.png`
# MAGIC - **Output table:** `ubereats.silver_invoice_extracted`
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## ⚙️ Technologies Used
# MAGIC - **Databricks** (Notebook + Delta Lake)
# MAGIC - **Azure Data Lake Storage (ABFSS)**
# MAGIC - **OpenAI GPT-4 Turbo with Vision**
# MAGIC - **Python (PIL, base64, requests)**
# MAGIC - **MLflow Deployments / External Model Serving**
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## 🧩 Pipeline Steps
# MAGIC
# MAGIC ### 1. Load Invoice Images
# MAGIC Reads all `.png` images from the specified ABFSS location using the `binaryFile` format:
# MAGIC ```python
# MAGIC spark.read.format("binaryFile")
# MAGIC      .option("pathGlobFilter", "*.png")
# MAGIC      .load("abfss://<...>/invoices")
# MAGIC ```
# MAGIC
# MAGIC ### 2. Resize and Compress
# MAGIC - Resizes each image to max 1024x1024
# MAGIC - Converts to JPEG format
# MAGIC - Compresses to ensure payload < 4MB (OpenAI limit)
# MAGIC
# MAGIC ```python
# MAGIC img = Image.open(BytesIO(image_bytes)).convert("RGB")
# MAGIC img.thumbnail((1024, 1024))
# MAGIC img.save(buffer, format="JPEG", quality=60, optimize=True)
# MAGIC ```
# MAGIC
# MAGIC ### 3. Encode to base64
# MAGIC The resized image is encoded to base64 and embedded into the OpenAI API request as a `data:image/jpeg;base64,...` URL.
# MAGIC
# MAGIC ### 4. Invoke External Endpoint
# MAGIC Sends a prompt and the image to the OpenAI model via a deployed endpoint (created with `mlflow.deployments`).
# MAGIC
# MAGIC Prompt example:
# MAGIC > "Extract structured JSON with: restaurant_name, cnpj, invoice_no, invoice_date, gross_revenue, commission_rate, tax_amount, total_amount"
# MAGIC
# MAGIC ### 5. Parse the Response
# MAGIC The response is a string containing a markdown-wrapped JSON. The script extracts and parses it:
# MAGIC ```python
# MAGIC content = response.json()["choices"][0]["message"]["content"]
# MAGIC data = json.loads(content.split("```json")[1].split("```") [0].strip())
# MAGIC ```
# MAGIC
# MAGIC ### 6. Save to Delta Table
# MAGIC Finally, results are saved to a managed Delta table:
# MAGIC ```python
# MAGIC result_df.write.mode("overwrite").format("delta").saveAsTable("ubereats.silver_invoice_extracted")
# MAGIC ```
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## ✅ Output Schema
# MAGIC ```sql
# MAGIC CREATE TABLE ubereats.silver_invoice_extracted (
# MAGIC   file_name STRING,
# MAGIC   restaurant_name STRING,
# MAGIC   cnpj STRING,
# MAGIC   invoice_no STRING,
# MAGIC   invoice_date STRING,
# MAGIC   gross_revenue STRING,
# MAGIC   commission_rate STRING,
# MAGIC   tax_amount STRING,
# MAGIC   total_amount STRING
# MAGIC );
# MAGIC ```
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## ✨ Authors
# MAGIC - **Luan Moreno**  
# MAGIC Lead Data Engineer | Databricks Expert | Founder of Engenharia de Dados Academy
# MAGIC

# COMMAND ----------

from mlflow.deployments import get_deploy_client

client = get_deploy_client("databricks")
client.delete_endpoint("openai-invoice-extractor")

# COMMAND ----------

import mlflow.deployments

client = mlflow.deployments.get_deploy_client("databricks")

openai_api_key = "API_KEY"

client.create_endpoint(
    name="openai-invoice-extractor",
    config={
        "served_entities": [{
            "external_model": {
                "name": "gpt-4-turbo",
                "provider": "openai",
                "task": "llm/v1/chat",
                "openai_config": {
                    "openai_api_key_plaintext": openai_api_key,
                    "openai_api_type": "openai",
                    "openai_api_base": "https://api.openai.com/v1"
                }
            }
        }]
    }
)

# COMMAND ----------

from pyspark.sql.functions import input_file_name
from PIL import Image
from io import BytesIO
import base64
import requests
import json

df = (
    spark.read.format("binaryFile")
    .option("pathGlobFilter", "*.png")
    .load("abfss://owshq-shadow-traffic@owshqblobstg.dfs.core.windows.net/invoices/")
    .withColumnRenamed("content", "data")
    .withColumnRenamed("path", "file_name")
)

extracted_data = []

for row in df.collect():
    image_bytes = row["data"]
    file_name = row["file_name"]

    try:
        img = Image.open(BytesIO(image_bytes)).convert("RGB")
        img.thumbnail((1024, 1024))

        buffer = BytesIO()
        img.save(buffer, format="JPEG", quality=60, optimize=True)
        resized_bytes = buffer.getvalue()

        if len(resized_bytes) > 4194304:
            print(f"⚠️ Skipping large file: {file_name}")
            continue

        encoded_image = base64.b64encode(resized_bytes).decode()

        prompt_text = (
            "Extract structured JSON with: "
            "restaurant_name, cnpj, invoice_no, invoice_date, "
            "gross_revenue, commission_rate, tax_amount, total_amount"
        )

        payload = {
            "model": "openai-invoice-extractor",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        { "type": "text", "text": prompt_text },
                        { "type": "image_url", "image_url": { "url": f"data:image/jpeg;base64,{encoded_image}" } }
                    ]
                }
            ]
        }

        headers = {
            "Authorization": "Bearer {DAPI_TOKEN}",
        }

        response = requests.post(
            "https://adb-2090585310411504.4.azuredatabricks.net/serving-endpoints/openai-invoice-extractor/invocations",
            headers=headers,
            json=payload
        )

        if response.ok:
            content = response.json()["choices"][0]["message"]["content"]
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            data = json.loads(content)
            data["file_name"] = file_name
            extracted_data.append(data)
    except Exception as e:
        print(f"❌ Failed: {file_name} -> {e}")

# COMMAND ----------

if extracted_data:
    result_df = spark.createDataFrame(extracted_data)
    result_df.write.mode("overwrite").format("delta").saveAsTable("ubereats.default.silver_invoice_extracted")
    display(result_df)
else:
    print("❗No data extracted.")