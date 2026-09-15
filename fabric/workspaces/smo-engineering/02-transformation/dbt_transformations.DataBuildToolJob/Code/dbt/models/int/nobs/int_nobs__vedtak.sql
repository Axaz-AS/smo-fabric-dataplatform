WITH vedtak AS (
    SELECT * FROM {{ ref('src_nobs__statvedtak') }}
),

active AS (
    SELECT *
    FROM vedtak
    WHERE is_deleted = 0 OR is_deleted IS NULL
)

SELECT * FROM active
