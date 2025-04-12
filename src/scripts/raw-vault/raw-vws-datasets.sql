CREATE STREAMING LIVE VIEW raw_vw_mssql_users
AS  
SELECT
  sha1(UPPER(TRIM(cpf))) AS hk_cpf,
  cpf AS cpf,
  current_timestamp() AS load_ts,
  "mssql" AS source,
  uuid,
  user_id,
  CONCAT_WS(' ', first_name, last_name) AS name,
  CAST(birthday AS DATE) AS date_birth,
  phone_number,
  company_name,
  job,
  country,
  dt_current_timestamp
FROM STREAM(LIVE.bronze_mssql_users);


CREATE STREAMING LIVE VIEW raw_vw_postgres_drivers
AS  
SELECT
  sha1(UPPER(TRIM(license_number))) AS hk_license_number,
  license_number AS license_number,
  current_timestamp() AS load_ts,
  "postgres" AS source,
  uuid,
  driver_id,
  CONCAT_WS(' ', first_name, last_name) AS name,
  CAST(date_birth AS DATE) AS date_birth,
  phone_number,
  vehicle_make AS company_name,
  city,
  country,
  vehicle_year,
  vehicle_model,
  vehicle_license_plate,
  vehicle_type,
  dt_current_timestamp
FROM STREAM(LIVE.bronze_postgres_drivers);

CREATE STREAMING LIVE VIEW raw_vw_mysql_restaurants
AS  
SELECT
  sha1(UPPER(TRIM(cnpj))) AS hk_cnpj,
  cnpj AS cnpj,
  current_timestamp() AS load_ts,
  "mysql" AS source,
  restaurant_id,
  uuid,
  name,
  phone_number,
  city,
  country,
  address,
  average_rating,
  cuisine_type,
  opening_time,
  closing_time,
  num_reviews,
  dt_current_timestamp
FROM STREAM(LIVE.bronze_mysql_restaurants);

CREATE STREAMING LIVE VIEW raw_vw_kafka_orders
AS  
SELECT
  sha1(UPPER(TRIM(order_id))) AS hk_order_id,
  order_id AS order_id,
  current_timestamp() AS load_ts,
  "kafka" AS source,
  CAST(order_date AS TIMESTAMP) AS order_date,
  user_key AS user_id,
  driver_key AS driver_license_number,
  restaurant_key AS restaurant_cnpj,
  payment_id,
  total_amount,
  dt_current_timestamp
FROM STREAM(LIVE.bronze_kafka_orders);

CREATE STREAMING LIVE VIEW raw_vw_kafka_status
AS  
SELECT
  sha1(UPPER(TRIM(order_identifier))) AS hk_order_id,
  order_identifier AS order_id,
  current_timestamp() AS load_ts,
  "kafka" AS source,
  status.status_name AS status,
  CAST(FROM_UNIXTIME(status.timestamp/1000) AS TIMESTAMP) AS timestamp,
  status_id,
  dt_current_timestamp
FROM STREAM(LIVE.bronze_kafka_status);
