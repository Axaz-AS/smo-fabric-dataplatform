WITH ordrelinje AS (
    SELECT * FROM {{ ref('src_nobs__statordrelinje') }}
),

active AS (
    SELECT *
    FROM ordrelinje
    WHERE is_deleted = 0 OR is_deleted IS NULL
)

SELECT * FROM active
