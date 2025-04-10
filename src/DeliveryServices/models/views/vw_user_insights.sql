SELECT
    u.name,
    u.company_type,
    f.total_orders,
    f.first_order_ts,
    f.last_order_ts
FROM {{ ref('fact_orders') }} f
JOIN {{ ref('dim_users') }} u ON f.user_key = u.user_key
