WITH ordrehistorikk AS (
    SELECT * FROM {{ ref('src_nobs__statordrehistorikk') }}
),

active AS (
    SELECT *
    FROM ordrehistorikk
    WHERE is_deleted = 0 OR is_deleted IS NULL
)

SELECT * FROM active
