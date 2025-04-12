# Databricks notebook source
# MAGIC %md
# MAGIC # Production-Grade Real-Time Prediction Script using MLFlow and Spark
# MAGIC -------------------------------------------------------------------
# MAGIC This script loads a trained ML model from MLflow Model Registry,
# MAGIC accepts new input data in real-time (manually or via REST proxy),
# MAGIC and returns predicted delivery times.
# MAGIC
# MAGIC Designed for Data Engineers who need to understand and deploy ML models
# MAGIC into production with full lifecycle visibility.

# COMMAND ----------

# MAGIC %md
# MAGIC # STEP 1 – Init & Publish Model

# COMMAND ----------

import mlflow.spark
from pyspark.sql import SparkSession, Row
from pyspark.sql.functions import col

spark = SparkSession.builder \
    .appName("RealTimeDeliveryPrediction") \
    .getOrCreate()

# COMMAND ----------

import mlflow

client = mlflow.tracking.MlflowClient()

models = client.search_registered_models()

for m in models:
    print(f"📦 Model name: {m.name}")

# COMMAND ----------

from mlflow.tracking import MlflowClient

client = MlflowClient()

client.transition_model_version_stage(
    name="ubereats",
    version=1,
    stage="Production",
    archive_existing_versions=True
)

# COMMAND ----------

from mlflow.tracking import MlflowClient

client = MlflowClient()

for mv in client.get_latest_versions("ubereats", stages=["Production", "Staging", "None"]):
    print(f"🔢 Version: {mv.version} | Stage: {mv.current_stage} | Status: {mv.status} | Run ID: {mv.run_id}")

# COMMAND ----------

# MAGIC %md
# MAGIC # STEP 2 – Load Production Model from MLflow

# COMMAND ----------

model_uri = "models:/ubereats/Production"
model = mlflow.spark.load_model(model_uri)

print("✅ Model loaded from MLflow Registry (Production Stage)")

# COMMAND ----------

# MAGIC %md
# MAGIC # STEP 3 – Define New Real-Time Input Data

# COMMAND ----------

sample_input = [
    {
        "job": "Engineer",
        "company_type": "Startup",
        "country": "BR",
        "total_orders": 12
    },
    {
        "job": "Designer",
        "company_type": "Enterprise",
        "country": "US",
        "total_orders": 3
    }
]

input_df = spark.createDataFrame([Row(**row) for row in sample_input])

# COMMAND ----------

# MAGIC %md
# MAGIC # STEP 4 – Run Inference and Get Prediction

# COMMAND ----------

predictions = model.transform(input_df)

# COMMAND ----------

# MAGIC %md
# MAGIC # STEP 5 – Display Results

# COMMAND ----------

result = predictions \
    .select("job", "company_type", "country", "total_orders", col("prediction").alias("predicted_delivery_minutes"))

result.show(truncate=False)

print("✅ Real-time predictions completed")