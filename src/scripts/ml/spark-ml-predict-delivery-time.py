# Databricks notebook source
# MAGIC %md
# MAGIC # MLFlow Pipeline – Predict Delivery Time Using Spark ML
# MAGIC
# MAGIC This module walks through an **end-to-end machine learning pipeline** designed specifically for **Data Engineers**, leveraging **Spark MLlib**, **Delta Lake**, and **MLflow** on Databricks.  
# MAGIC
# MAGIC The objective is to predict the **delivery time** of an order in minutes, based on enriched historical data stored in your existing **Business Data Vault (BDV)** model.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## 🧠 Problem Statement
# MAGIC
# MAGIC **How long will a given order take to be delivered?**
# MAGIC
# MAGIC We aim to build a model that predicts the delivery duration (in minutes) from the moment an order is placed until it reaches the "Delivered" status. 
# MAGIC
# MAGIC ML models need **raw + enriched inputs** that retain full **temporal and behavioral granularity**. Therefore, we source our data from the **BDV layer** rather than Information Delivery (which is flattened and consumer-oriented).
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## 🔁 Pipeline Overview
# MAGIC
# MAGIC | Step | Task | Purpose |
# MAGIC |------|------|---------|
# MAGIC | 1️⃣ | Load and join BDV data | Create features and label from PIT, BSAT, and BLINK tables |
# MAGIC | 2️⃣ | Feature engineering | Transform categorical + numerical values into ML features |
# MAGIC | 3️⃣ | Train model with Spark ML | Build a regression model and tune parameters |
# MAGIC | 4️⃣ | Log experiment in MLflow | Track runs, metrics, and register model artifact |
# MAGIC | 5️⃣ | Save predictions to Delta | Store predicted results for analysis or dashboarding |
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## Step 1: Load & Prepare Data from BDV
# MAGIC
# MAGIC - **`pit_user_order_status`** → used to compute the label (actual delivery time)
# MAGIC - **`bsat_users_enriched`** → provides contextual features such as job, country, company type
# MAGIC - **`blink_user_order_activity`** → behavioral feature: number of total past orders
# MAGIC
# MAGIC We calculate the label `delivery_time_minutes` as the difference between `status_ts` and `status_load_ts` for the "Delivered" rows.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## Step 2: Feature Engineering with Spark ML
# MAGIC
# MAGIC To prepare our features:
# MAGIC - **Categorical columns** (`job`, `company_type`, `country`) are encoded using `StringIndexer` + `OneHotEncoder`.
# MAGIC - **Numeric column** `total_orders` is passed through as-is.
# MAGIC - All features are combined using a `VectorAssembler` into a single `features` vector column.
# MAGIC
# MAGIC This enables distributed feature processing suitable for large-scale training.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## Step 3: Train the Regression Model
# MAGIC
# MAGIC We use `LinearRegression` from `pyspark.ml.regression`, which is fast, explainable, and interpretable.
# MAGIC
# MAGIC The model pipeline includes preprocessing + regression model. It’s trained on the Spark DataFrame entirely in-cluster — no need to `.toPandas()` or sample the data.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## Step 4: Track Results in MLflow
# MAGIC
# MAGIC All steps are tracked using `mlflow.start_run()` including:
# MAGIC - Model parameters (automatically tracked)
# MAGIC - R2 score and any other custom metrics (optional)
# MAGIC - Model artifact using `mlflow.spark.log_model()`
# MAGIC
# MAGIC The model can now be viewed and compared in the MLflow UI within the Databricks workspace.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## Step 5: Save Predictions to Delta Table
# MAGIC
# MAGIC After training, we run inference on the entire dataset and save the resulting predictions into:
# MAGIC
# MAGIC ```sql
# MAGIC ubereats.default.predicted_delivery_times
# MAGIC ```
# MAGIC
# MAGIC This table contains:
# MAGIC | Column              | Description                                |
# MAGIC |---------------------|--------------------------------------------|
# MAGIC | `job`               | User’s occupation                          |
# MAGIC | `company_type`      | User’s business type                       |
# MAGIC | `country`           | Country of user                            |
# MAGIC | `total_orders`      | Historical number of orders                |
# MAGIC | `predicted_minutes` | Model prediction for delivery time         |
# MAGIC | `delivery_time_minutes` | Actual observed delivery duration     |
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## 🧠 Key Takeaways for Data Engineers
# MAGIC
# MAGIC - **Train on raw + enriched BDV**, not flattened info delivery
# MAGIC - **No `.toPandas()` bottlenecks** — scalable on Spark ML
# MAGIC - **MLflow integration** lets you track models like code artifacts
# MAGIC - Predictions written to Delta can be used by Genie, dashboards, or alerts
# MAGIC
# MAGIC ---

# COMMAND ----------

# MAGIC %sql
# MAGIC
# MAGIC SELECT * 
# MAGIC FROM ubereats.default.pit_user_order_status
# MAGIC LIMIT 10;

# COMMAND ----------

import mlflow
import mlflow.spark
from pyspark.sql.functions import col, unix_timestamp
from pyspark.ml import Pipeline
from pyspark.ml.feature import StringIndexer, OneHotEncoder, VectorAssembler
from pyspark.ml.regression import LinearRegression

# COMMAND ----------

# MAGIC %md
# MAGIC # Step 1: Load & Join Data from BDV
# MAGIC - **`pit_user_order_status`** → used to compute the label (actual delivery time)
# MAGIC - **`bsat_users_enriched`** → provides contextual features such as job, country, company type
# MAGIC - **`blink_user_order_activity`** → behavioral feature: number of total past orders
# MAGIC
# MAGIC We calculate the label `delivery_time_minutes` as the difference between `status_ts` and `status_load_ts` for the "Delivered" rows.
# MAGIC

# COMMAND ----------

pit = spark.table("ubereats.default.pit_user_order_status")
users = spark.table("ubereats.default.bsat_users_enriched")
activity = spark.table("ubereats.default.blink_user_order_activity")

delivery = pit \
    .filter(col("status") == "Delivered") \
    .withColumn("delivery_time_minutes",
                (unix_timestamp("status_ts") - unix_timestamp("status_load_ts")) / 60)


df = delivery \
    .join(users, on="hk_cpf", how="left") \
    .join(activity, on="hk_cpf", how="left") \
    .select("hk_cpf", "job", "company_type", "country", "total_orders", "delivery_time_minutes") \
    .dropna()

# COMMAND ----------

# MAGIC %md
# MAGIC # Step 2: Feature Engineering with Spark ML
# MAGIC
# MAGIC To prepare our features:
# MAGIC - **Categorical columns** (`job`, `company_type`, `country`) are encoded using `StringIndexer` + `OneHotEncoder`.
# MAGIC - **Numeric column** `total_orders` is passed through as-is.
# MAGIC - All features are combined using a `VectorAssembler` into a single `features` vector column.
# MAGIC
# MAGIC This enables distributed feature processing suitable for large-scale training.

# COMMAND ----------

categorical_cols = ["job", "company_type", "country"]

indexers = [StringIndexer(inputCol=col, outputCol=f"{col}_idx", handleInvalid="keep") for col in categorical_cols]
encoders = [OneHotEncoder(inputCol=f"{col}_idx", outputCol=f"{col}_vec") for col in categorical_cols]

assembler = VectorAssembler(
    inputCols=[f"{col}_vec" for col in categorical_cols] + ["total_orders"],
    outputCol="features"
)

lr = LinearRegression(featuresCol="features", labelCol="delivery_time_minutes")

pipeline = Pipeline(stages=indexers + encoders + [assembler, lr])

# COMMAND ----------

# MAGIC %md
# MAGIC # Step 3: Train Model with MLflow Tracking
# MAGIC We use `LinearRegression` from `pyspark.ml.regression`, which is fast, explainable, and interpretable.
# MAGIC
# MAGIC The model pipeline includes preprocessing + regression model. It’s trained on the Spark DataFrame entirely in-cluster — no need to `.toPandas()` or sample the data.
# MAGIC

# COMMAND ----------

df = df.limit(1000).cache()
df.count()

with mlflow.start_run(run_name="spark_lr_delivery_time") as run:
    model = pipeline.fit(df)

    mlflow.spark.log_model(model, "model")
    print("✅ Spark ML model trained and logged.")

# COMMAND ----------

# MAGIC %md
# MAGIC # Step 4: Run Predictions and Save to Delta Table
# MAGIC All steps are tracked using `mlflow.start_run()` including:
# MAGIC - Model parameters (automatically tracked)
# MAGIC - R2 score and any other custom metrics (optional)
# MAGIC - Model artifact using `mlflow.spark.log_model()`
# MAGIC
# MAGIC The model can now be viewed and compared in the MLflow UI within the Databricks workspace.

# COMMAND ----------

predictions = model.transform(df)

predictions \
    .select("job", "company_type", "country", "total_orders", "prediction", "delivery_time_minutes") \
    .withColumnRenamed("prediction", "predicted_minutes") \
    .write.format("delta").mode("overwrite").saveAsTable("ubereats.default.predicted_delivery_times")

print("✅ Predictions saved to 'ubereats.default.predicted_delivery_times'")

# COMMAND ----------

# MAGIC %sql
# MAGIC
# MAGIC SELECT DISTINCT
# MAGIC   job,
# MAGIC   company_type,
# MAGIC   country,
# MAGIC   total_orders,
# MAGIC   
# MAGIC   ROUND(
# MAGIC     GREATEST(LEAST(predicted_minutes, 90), 10), 0
# MAGIC   ) AS predicted_minutes_masked,
# MAGIC   
# MAGIC   ROUND(
# MAGIC     GREATEST(LEAST(delivery_time_minutes, 90), 10), 0
# MAGIC   ) AS delivery_time_minutes_masked
# MAGIC
# MAGIC FROM ubereats.default.predicted_delivery_times
# MAGIC LIMIT 5;