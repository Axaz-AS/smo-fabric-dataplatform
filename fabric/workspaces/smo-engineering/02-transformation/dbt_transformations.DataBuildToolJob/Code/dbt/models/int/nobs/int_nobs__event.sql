WITH event AS (
    SELECT * FROM {{ ref('src_nobs__statevent') }}
),

active AS (
    SELECT *
    FROM event
    WHERE is_deleted = 0 OR is_deleted IS NULL
)

SELECT * FROM active
