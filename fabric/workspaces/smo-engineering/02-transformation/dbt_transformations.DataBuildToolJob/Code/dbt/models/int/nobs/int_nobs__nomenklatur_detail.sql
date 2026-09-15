WITH nomenklatur_detail AS (
    SELECT * FROM {{ ref('src_nobs__statnomenklatur_detail') }}
),

active AS (
    SELECT *
    FROM nomenklatur_detail
    WHERE is_deleted = 0 OR is_deleted IS NULL
)

SELECT * FROM active
