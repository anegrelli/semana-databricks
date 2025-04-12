CREATE OR REFRESH STREAMING LIVE TABLE link_order_user
AS
SELECT DISTINCT
  sha1(CONCAT(
    sha1(UPPER(TRIM(order_id))),
    sha1(UPPER(TRIM(user_id)))
  )) AS hk_link_order_user,

  sha1(UPPER(TRIM(order_id))) AS hk_order_id,
  sha1(UPPER(TRIM(user_id))) AS hk_cpf,
  current_timestamp() AS load_ts,
  "kafka" AS source
FROM STREAM(live.raw_vw_kafka_orders)
WHERE order_id IS NOT NULL AND user_id IS NOT NULL;

CREATE OR REFRESH STREAMING LIVE TABLE link_order_driver
AS
SELECT DISTINCT
  sha1(CONCAT(
    sha1(UPPER(TRIM(order_id))),
    sha1(UPPER(TRIM(driver_license_number)))
  )) AS hk_link_order_driver,

  sha1(UPPER(TRIM(order_id))) AS hk_order_id,
  sha1(UPPER(TRIM(driver_license_number))) AS hk_license_number,
  current_timestamp() AS load_ts,
  "kafka" AS source
FROM STREAM(live.raw_vw_kafka_orders)
WHERE order_id IS NOT NULL AND driver_license_number IS NOT NULL;

CREATE OR REFRESH STREAMING LIVE TABLE link_order_restaurant
AS
SELECT DISTINCT
  sha1(CONCAT(
    sha1(UPPER(TRIM(order_id))),
    sha1(UPPER(TRIM(restaurant_cnpj)))
  )) AS hk_link_order_restaurant,

  sha1(UPPER(TRIM(order_id))) AS hk_order_id,
  sha1(UPPER(TRIM(restaurant_cnpj))) AS hk_cnpj,
  current_timestamp() AS load_ts,
  "kafka" AS source
FROM STREAM(live.raw_vw_kafka_orders)
WHERE order_id IS NOT NULL AND restaurant_cnpj IS NOT NULL;