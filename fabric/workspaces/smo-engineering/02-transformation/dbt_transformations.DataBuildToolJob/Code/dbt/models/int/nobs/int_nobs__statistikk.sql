WITH statistikk AS (
    SELECT * FROM {{ ref('src_nobs__stat_statistikk') }}
),

active AS (
    SELECT *
    FROM statistikk
    WHERE is_deleted = 0 OR is_deleted IS NULL
)

SELECT * FROM active
