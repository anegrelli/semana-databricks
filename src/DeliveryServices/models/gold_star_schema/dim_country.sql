
SELECT DISTINCT
    country,
    country_name
FROM {{ source('bdv', 'ref_country') }}
