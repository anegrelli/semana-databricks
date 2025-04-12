CREATE OR REFRESH STREAMING LIVE TABLE hub_users
(
  hk_cpf STRING NOT NULL,
  cpf STRING NOT NULL,
  load_ts TIMESTAMP,
  source STRING
  
  CONSTRAINT valid_hk_cpf EXPECT (hk_cpf IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_cpf EXPECT (cpf IS NOT NULL) ON VIOLATION DROP ROW
)
AS 
SELECT DISTINCT
    hk_cpf,
    cpf,
    load_ts,
    "dlt" AS source
FROM STREAM(live.raw_vw_mssql_users);

CREATE OR REFRESH STREAMING LIVE TABLE hub_drivers
(
  hk_license_number STRING NOT NULL,
  license_number STRING NOT NULL,
  load_ts TIMESTAMP,
  source STRING

  CONSTRAINT valid_hk_license_number EXPECT (hk_license_number IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_license_number EXPECT (license_number IS NOT NULL) ON VIOLATION DROP ROW
)
AS 
SELECT DISTINCT
  hk_license_number,
  license_number,
  load_ts,
  "postgres" AS source
FROM STREAM(live.raw_vw_postgres_drivers);

CREATE OR REFRESH STREAMING LIVE TABLE hub_restaurants
(
  hk_cnpj STRING NOT NULL,
  cnpj STRING NOT NULL,
  load_ts TIMESTAMP,
  source STRING

  CONSTRAINT valid_hk_cnpj EXPECT (hk_cnpj IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_cnpj EXPECT (cnpj IS NOT NULL) ON VIOLATION DROP ROW
)
AS 
SELECT DISTINCT
  hk_cnpj,
  cnpj,
  load_ts,
  "mysql" AS source
FROM STREAM(live.raw_vw_mysql_restaurants);

CREATE OR REFRESH STREAMING LIVE TABLE hub_orders
(
  hk_order_id STRING NOT NULL,
  order_id STRING NOT NULL,
  load_ts TIMESTAMP,
  source STRING
  
  CONSTRAINT valid_hk_order_id EXPECT (hk_order_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_order_id EXPECT (order_id IS NOT NULL) ON VIOLATION DROP ROW
)
AS 
WITH unq_order_id AS
(
  SELECT DISTINCT
    hk_order_id,
    order_id,
    "dlt" AS source
  FROM STREAM(live.raw_vw_kafka_orders)
  UNION ALL
  SELECT DISTINCT
    hk_order_id,
    order_id,
    "dlt" AS source
  FROM STREAM(live.raw_vw_kafka_status)
)
SELECT DISTINCT hk_order_id, order_id, current_timestamp() AS load_ts, source
FROM unq_order_id 