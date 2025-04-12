CREATE OR REFRESH LIVE TABLE bhub_active_users
AS
SELECT DISTINCT
  u.hk_cpf,
  u.cpf,
  u.load_ts,
  'bdv' AS source
FROM live.hub_users u
JOIN live.link_order_user l
  ON u.hk_cpf = l.hk_cpf;

CREATE OR REFRESH LIVE TABLE blink_user_order_activity
AS
SELECT
  hk_cpf,
  hk_order_id,
  COUNT(*) AS total_orders,
  MIN(load_ts) AS first_order_ts,
  MAX(load_ts) AS last_order_ts
FROM live.link_order_user
GROUP BY hk_cpf, hk_order_id;

CREATE OR REFRESH LIVE TABLE bsat_users_enriched
AS
SELECT
  su.hk_cpf,
  su.name,
  su.date_birth,
  CASE 
    WHEN su.date_birth > '2100-01-01' THEN NULL
    ELSE su.date_birth
  END AS cleaned_birth_date,
  su.job,
  CASE 
    WHEN su.company_name IS NULL THEN 'Independente'
    ELSE su.company_name
  END AS company_type,
  su.country,
  su.load_ts
FROM live.sat_users su;

CREATE OR REFRESH LIVE TABLE pit_user_order_status
AS
SELECT
  l.hk_cpf,
  l.hk_order_id,
  s.status,
  s.status_ts,
  s.load_ts AS status_load_ts
FROM live.link_order_user l
JOIN live.sat_order_status s
  ON l.hk_order_id = s.hk_order_id;

CREATE OR REFRESH LIVE TABLE bridge_order_status_flow
AS
SELECT
  hk_order_id,
  COLLECT_LIST(status) AS status_flow
FROM (
  SELECT hk_order_id, status
  FROM live.sat_order_status
  ORDER BY hk_order_id, status_ts
) AS ordered_status
GROUP BY hk_order_id;

CREATE OR REFRESH LIVE TABLE ref_country
AS
SELECT DISTINCT
  country,
  CASE
    WHEN country = 'BR' THEN 'Brasil'
    WHEN country = 'US' THEN 'United States'
    ELSE 'Unknown'
  END AS country_name
FROM (
  SELECT country FROM live.sat_users
  UNION ALL
  SELECT country FROM live.sat_drivers
  UNION ALL
  SELECT country FROM live.sat_restaurants
);

CREATE OR REFRESH LIVE TABLE latest_order_status
AS
SELECT *
FROM (
  SELECT
    hk_order_id,
    status,
    status_ts,
    load_ts AS status_load_ts,
    ROW_NUMBER() OVER (PARTITION BY hk_order_id ORDER BY status_ts DESC) AS rn
  FROM live.sat_order_status
)
WHERE rn = 1;