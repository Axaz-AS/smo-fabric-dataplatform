WITH time_registrations AS (
    SELECT * FROM {{ ref('src_nobs__stattime') }}
),

active AS (
    SELECT *
    FROM time_registrations
    WHERE is_deleted = 0 OR is_deleted IS NULL
)

SELECT * FROM active
