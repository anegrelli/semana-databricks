CREATE OR REFRESH STREAMING LIVE TABLE sat_users
AS
SELECT
  sha1(UPPER(TRIM(cpf))) AS hk_cpf,
  current_timestamp() AS load_ts,
  dt_current_timestamp AS effective_ts,
  uuid,
  user_id,
  name,
  date_birth,
  phone_number,
  company_name,
  job,
  country
FROM STREAM(live.raw_vw_mssql_users)
WHERE cpf IS NOT NULL;

CREATE OR REFRESH STREAMING LIVE TABLE sat_drivers
AS
SELECT
  sha1(UPPER(TRIM(license_number))) AS hk_license_number,
  current_timestamp() AS load_ts,
  dt_current_timestamp AS effective_ts,
  uuid,
  driver_id,
  name,
  date_birth,
  phone_number,
  company_name,
  city,
  country,
  vehicle_year,
  vehicle_model,
  vehicle_license_plate,
  vehicle_type
FROM STREAM(live.raw_vw_postgres_drivers)
WHERE license_number IS NOT NULL;

CREATE OR REFRESH STREAMING LIVE TABLE sat_restaurants
AS
SELECT
  sha1(UPPER(TRIM(cnpj))) AS hk_cnpj,
  current_timestamp() AS load_ts,
  dt_current_timestamp AS effective_ts,
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
  num_reviews
FROM STREAM(live.raw_vw_mysql_restaurants)
WHERE cnpj IS NOT NULL;

CREATE OR REFRESH STREAMING LIVE TABLE sat_order_details
AS
SELECT
  sha1(UPPER(TRIM(order_id))) AS hk_order_id,
  current_timestamp() AS load_ts,
  dt_current_timestamp AS effective_ts,
  order_date,
  payment_id,
  total_amount
FROM STREAM(live.raw_vw_kafka_orders)
WHERE order_id IS NOT NULL;

CREATE OR REFRESH STREAMING LIVE TABLE sat_order_status
AS
SELECT
  sha1(UPPER(TRIM(order_id))) AS hk_order_id,
  current_timestamp() AS load_ts,
  dt_current_timestamp AS effective_ts,
  status,
  timestamp AS status_ts,
  status_id
FROM STREAM(live.raw_vw_kafka_status)
WHERE order_id IS NOT NULL;
