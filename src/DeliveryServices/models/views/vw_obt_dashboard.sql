SELECT
    hk_order_id,
    name,
    status,
    status_ts,
    total_orders,
    country_name
FROM {{ ref('obt_orders') }}
WHERE status IS NOT NULL
