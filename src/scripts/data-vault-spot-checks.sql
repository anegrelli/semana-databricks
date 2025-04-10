
SELECT sha1(UPPER(TRIM('019.266.934-95')))

WITH user_history AS (
  SELECT *
  FROM live.sat_users
  WHERE hk_cpf = 'your_hashed_hk_cpf_here'
  ORDER BY load_ts
),
user_orders AS (
  SELECT *
  FROM live.link_order_user
  WHERE hk_cpf = 'your_hashed_hk_cpf_here'
),
order_statuses AS (
  SELECT *
  FROM live.sat_order_status
  WHERE hk_order_id IN (SELECT hk_order_id FROM user_orders)
  ORDER BY status_ts
)
SELECT
  u.name,
  u.date_birth,
  u.job,
  o.hk_order_id,
  s.status,
  s.status_ts,
  s.load_ts AS status_load_ts
FROM user_history u
JOIN user_orders o ON u.hk_cpf = o.hk_cpf
JOIN order_statuses s ON o.hk_order_id = s.hk_order_id
ORDER BY s.status_ts;

SELECT hk_cpf, COUNT(*) AS orders_placed
FROM live.link_order_user
GROUP BY hk_cpf
ORDER BY orders_placed DESC
LIMIT 10;

SELECT COUNT(*) AS total_users, COUNT(DISTINCT hk_cpf) AS unique_users
FROM live.hub_users;

SELECT
  u.cpf,
  u.name,
  s.status,
  s.status_ts
FROM live.link_order_user l
JOIN live.sat_users u ON l.hk_cpf = u.hk_cpf
JOIN live.bdv_latest_order_status s ON l.hk_order_id = s.hk_order_id
LIMIT 10;

SELECT *
FROM live.sat_users
ORDER BY load_ts DESC
LIMIT 5;

SELECT *
FROM live.bsat_users_enriched
WHERE company_type IS NOT NULL
LIMIT 5;

SELECT *
FROM live.bsat_users_enriched
WHERE company_type IS NOT NULL
LIMIT 5;

SELECT *
FROM live.bdv_latest_order_status
ORDER BY status_ts DESC
LIMIT 10;

SELECT *
FROM live.sat_order_status
WHERE hk_order_id = '<some_order_id>'
ORDER BY status_ts;

SELECT *
FROM live.bdv_latest_order_status
WHERE hk_order_id = '<some_order_id>';

SELECT COUNT(*) AS total_users, COUNT(DISTINCT hk_cpf) AS unique_users
FROM hub_users;

SELECT hk_cpf, COUNT(*) AS order_count
FROM link_order_user
GROUP BY hk_cpf
ORDER BY order_count DESC
LIMIT 10;

SELECT *
FROM bsat_users_enriched
ORDER BY load_ts DESC
LIMIT 10;

SELECT *
FROM pit_user_order_status
WHERE hk_order_id IS NOT NULL
ORDER BY status_ts DESC
LIMIT 10;

SELECT *
FROM bridge_order_status_flow
WHERE hk_order_id = '<sample_order_id>';

SELECT
  hu.cpf,
  u.name,
  u.company_type,
  lo.hk_order_id,
  pit.status,
  pit.status_ts,
  bridge.status_flow
FROM hub_users hu
JOIN link_order_user lo ON hu.hk_cpf = lo.hk_cpf
LEFT JOIN pit_user_order_status pit ON lo.hk_order_id = pit.hk_order_id
LEFT JOIN bsat_users_enriched u ON hu.hk_cpf = u.hk_cpf
LEFT JOIN bridge_order_status_flow bridge ON lo.hk_order_id = bridge.hk_order_id
LIMIT 10;