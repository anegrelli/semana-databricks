CREATE OR REFRESH STREAMING TABLE ubereats.default.bronze_mssql_users
AS SELECT 
  *,
  _metadata.file_path AS source_file,
  _metadata.file_modification_time AS ingestion_time
FROM STREAM read_files(
  'abfss://owshq-shadow-traffic@owshqblobstg.dfs.core.windows.net/mssql/users/', 
  format => 'json',
  inferSchema => true,
  maxFilesPerTrigger => 10000
);

CREATE OR REFRESH STREAMING TABLE ubereats.default.bronze_postgres_drivers
AS SELECT 
  *,
  _metadata.file_path AS source_file,
  _metadata.file_modification_time AS ingestion_time
FROM STREAM read_files(
  'abfss://owshq-shadow-traffic@owshqblobstg.dfs.core.windows.net/postgres/drivers/', 
  format => 'json',
  inferSchema => true,
  maxFilesPerTrigger => 10000
);

CREATE OR REFRESH STREAMING TABLE ubereats.default.bronze_mysql_restaurants
AS SELECT 
  *,
  _metadata.file_path AS source_file,
  _metadata.file_modification_time AS ingestion_time
FROM STREAM read_files(
  'abfss://owshq-shadow-traffic@owshqblobstg.dfs.core.windows.net/mysql/restaurants/', 
  format => 'json',
  inferSchema => true,
  maxFilesPerTrigger => 10000
);

CREATE OR REFRESH STREAMING TABLE ubereats.default.bronze_kafka_orders
AS SELECT 
  *,
  _metadata.file_path AS source_file,
  _metadata.file_modification_time AS ingestion_time
FROM STREAM read_files(
  'abfss://owshq-shadow-traffic@owshqblobstg.dfs.core.windows.net/kafka/orders/', 
  format => 'json',
  inferSchema => true,
  maxFilesPerTrigger => 10000
);

CREATE OR REFRESH STREAMING TABLE ubereats.default.bronze_kafka_status
AS SELECT 
  *,
  _metadata.file_path AS source_file,
  _metadata.file_modification_time AS ingestion_time
FROM STREAM read_files(
  'abfss://owshq-shadow-traffic@owshqblobstg.dfs.core.windows.net/kafka/status/', 
  format => 'json',
  inferSchema => true,
  maxFilesPerTrigger => 10000
);
