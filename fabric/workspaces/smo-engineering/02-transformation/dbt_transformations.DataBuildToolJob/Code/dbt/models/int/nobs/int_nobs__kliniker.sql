WITH kliniker AS (
    SELECT * FROM {{ ref('src_nobs__statkliniker') }}
),

active AS (
    SELECT *
    FROM kliniker
    WHERE is_deleted = 0 OR is_deleted IS NULL
)

SELECT * FROM active
