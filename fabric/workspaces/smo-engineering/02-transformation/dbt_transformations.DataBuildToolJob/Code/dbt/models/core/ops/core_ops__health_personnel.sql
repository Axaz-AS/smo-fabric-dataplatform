/*
    Model: core_ops__health_personnel
    Domain: Operations (Ops)
    Grain: 1 row per external healthcare practitioner (pk_health_personnel_id)

    Business Logic:
    - Represents external healthcare practitioners (fastleger, sykehusleger,
      spesialister, fysioterapeuter, ergoterapeuter, rekvirenter) who interact
      with patients but are NOT internal employees of Sophies Minde.
    - Sourced from base_nobs__exp_helsepersonell.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_helsepersonell') }}
),

renamed AS (
    SELECT
        CAST(pk_helsepersonell_id AS VARCHAR(64))           AS pk_health_personnel_id,
        CAST(employee_id_number AS VARCHAR(50))             AS hpr_number,
        CAST(first_name AS VARCHAR(100))                    AS first_name,
        CAST(last_name AS VARCHAR(100))                     AS last_name,
        CAST(CASE
            WHEN first_name IS NOT NULL OR last_name IS NOT NULL
            THEN TRIM(CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, '')))
            ELSE NULL
        END AS VARCHAR(255))                               AS full_name,
        CAST(category AS VARCHAR(100))                      AS practitioner_category,
        CAST(profession AS VARCHAR(100))                    AS profession,
        TRY_CAST(created_at AS DATETIME2(6))                AS created_at,
        CAST(created_by AS VARCHAR(100))                    AS created_by,
        TRY_CAST(modified_at AS DATETIME2(6))               AS modified_at,
        CAST(modified_by AS VARCHAR(100))                   AS modified_by
    FROM source
)

SELECT *
FROM renamed
