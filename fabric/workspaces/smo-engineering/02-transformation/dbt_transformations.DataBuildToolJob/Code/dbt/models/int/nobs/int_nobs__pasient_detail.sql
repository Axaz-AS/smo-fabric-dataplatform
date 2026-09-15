WITH pasient_detail AS (
    SELECT * FROM {{ ref('src_nobs__statpasient_detail') }}
),

active AS (
    SELECT *
    FROM pasient_detail
    WHERE (
            (is_deleted != 9 AND is_deleted = 0)
            OR is_deleted IS NULL
          )
        AND dummy IS NULL
)

SELECT * FROM active
