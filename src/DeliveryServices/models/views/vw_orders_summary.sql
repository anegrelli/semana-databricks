SELECT
    status,
    COUNT(*) AS total_orders,
    MAX(status_ts) AS last_status_ts
FROM {{ ref('fact_orders') }}
GROUP BY status
