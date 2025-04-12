-- DROP TABLE IF EXISTS ubereats.default.bronze_mssql_users;
-- DROP TABLE IF EXISTS ubereats.default.bronze_postgres_drivers;
-- DROP TABLE IF EXISTS ubereats.default.bronze_mysql_restaurants;
-- DROP TABLE IF EXISTS ubereats.default.bronze_kafka_orders;
-- DROP TABLE IF EXISTS ubereats.default.bronze_kafka_status;

CREATE OR REPLACE TABLE ubereats.default.bronze_mssql_users (
  user_id BIGINT,
  country STRING,
  birthday STRING,
  job STRING,
  phone_number STRING,
  uuid STRING,
  last_name STRING,
  first_name STRING,
  cpf STRING,
  company_name STRING,
  dt_current_timestamp TIMESTAMP,
  source_file STRING,
  ingestion_time TIMESTAMP,
  partition_date STRING
)
USING DELTA
CLUSTER BY AUTO
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true', 
  'delta.enableChangeDataFeed' = 'true',
  'delta.targetFileSize' = '256m',
  'delta.checkpoint.writeStatsAsJson' = 'true',
  'delta.tuneFileSizesForRewrites' = 'true'
);

CREATE OR REPLACE TABLE ubereats.default.bronze_postgres_drivers (
  country STRING,
  date_birth STRING,
  city STRING,
  vehicle_year INT,
  phone_number STRING,
  license_number STRING,
  vehicle_make STRING,
  uuid STRING,
  vehicle_model STRING,
  driver_id BIGINT,
  last_name STRING,
  first_name STRING,
  vehicle_license_plate STRING,
  vehicle_type STRING,
  dt_current_timestamp TIMESTAMP,
  source_file STRING,
  ingestion_time TIMESTAMP,
  partition_date STRING
)
USING DELTA
CLUSTER BY AUTO
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true', 
  'delta.enableChangeDataFeed' = 'true',
  'delta.targetFileSize' = '256m',
  'delta.checkpoint.writeStatsAsJson' = 'true',
  'delta.tuneFileSizesForRewrites' = 'true'
);

CREATE OR REPLACE TABLE ubereats.default.bronze_mysql_restaurants (
  country STRING,
  city STRING,
  restaurant_id BIGINT,
  phone_number STRING,
  cnpj STRING,
  average_rating DOUBLE,
  name STRING,
  uuid STRING,
  address STRING,
  opening_time STRING,
  cuisine_type STRING,
  closing_time STRING,
  num_reviews INT,
  dt_current_timestamp TIMESTAMP,
  source_file STRING,
  ingestion_time TIMESTAMP,
  partition_date STRING
)
USING DELTA
CLUSTER BY AUTO
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true', 
  'delta.enableChangeDataFeed' = 'true',
  'delta.targetFileSize' = '256m',
  'delta.checkpoint.writeStatsAsJson' = 'true',
  'delta.tuneFileSizesForRewrites' = 'true'
);

CREATE OR REPLACE TABLE ubereats.default.bronze_kafka_orders (
  order_id STRING,
  user_key STRING,
  restaurant_key STRING,
  driver_key STRING,
  order_date STRING,
  total_amount DOUBLE,
  payment_id STRING,
  dt_current_timestamp TIMESTAMP,
  source_file STRING,
  ingestion_time TIMESTAMP,
  partition_date STRING
)
USING DELTA
CLUSTER BY AUTO
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true', 
  'delta.enableChangeDataFeed' = 'true',
  'delta.targetFileSize' = '256m',
  'delta.checkpoint.writeStatsAsJson' = 'true',
  'delta.tuneFileSizesForRewrites' = 'true'
);

CREATE OR REPLACE TABLE ubereats.default.bronze_kafka_status (
  status_id BIGINT,
  order_identifier STRING,
  status STRUCT<status_name: STRING, timestamp: BIGINT>,
  dt_current_timestamp TIMESTAMP,
  source_file STRING,
  ingestion_time TIMESTAMP,
  partition_date STRING
)
USING DELTA
CLUSTER BY AUTO
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true', 
  'delta.enableChangeDataFeed' = 'true',
  'delta.targetFileSize' = '256m',
  'delta.checkpoint.writeStatsAsJson' = 'true',
  'delta.tuneFileSizesForRewrites' = 'true'
);