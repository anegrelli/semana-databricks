SELECT
    u.hk_cpf AS user_key,
    u.name,
    u.cleaned_birth_date AS birth_date,
    u.job,
    u.company_type,
    c.country_name
FROM {{ source('bdv', 'bsat_users_enriched') }} u
LEFT JOIN {{ source('bdv', 'ref_country') }} c
ON u.country = c.country
