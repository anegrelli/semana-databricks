SELECT
    p.hk_order_id,
    p.hk_cpf AS user_key,
    u.name,
    u.cleaned_birth_date,
    u.company_type,
    c.country_name,
    s.status,
    s.status_ts,
    a.total_orders,
    a.first_order_ts,
    a.last_order_ts
FROM {{ source('bdv', 'pit_user_order_status') }} p
LEFT JOIN {{ source('bdv', 'bsat_users_enriched') }} u
ON p.hk_cpf = u.hk_cpf
LEFT JOIN {{ source('bdv', 'ref_country') }} c
ON u.country = c.country
LEFT JOIN {{ source('bdv', 'latest_order_status') }} s
ON p.hk_order_id = s.hk_order_id
LEFT JOIN {{ source('bdv', 'blink_user_order_activity') }} a
ON p.hk_order_id = a.hk_order_id
    AND p.hk_cpf = a.hk_cpf
