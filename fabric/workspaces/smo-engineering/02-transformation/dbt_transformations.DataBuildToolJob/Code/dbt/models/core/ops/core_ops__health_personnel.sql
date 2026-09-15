/*
    Model: core_ops__health_personnel
    Domain: Operations (Ops)
    Grain: 1 row per external healthcare practitioner (pk_health_personnel_id)

    Business Logic:
    - Represents external healthcare practitioners (fastleger, sykehusleger,
      spesialister, fysioterapeuter, ergoterapeuter, rekvirenter) who interact
      with patients but are NOT internal employees of Sophies Minde.
    - Sourced from base_nobs__helsepersonell.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__helsepersonell') }}
),

renamed AS (
    SELECT
        pk_helsepersonell_id                                AS pk_health_personnel_id,
        employee_id_number                                  AS hpr_number,
        first_name,
        last_name,
        CASE
            WHEN first_name IS NOT NULL OR last_name IS NOT NULL
            THEN TRIM(CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, '')))
            ELSE NULL
        END                                                AS full_name,
        category                                            AS practitioner_category,
        profession,
        created_at,
        created_by,
        modified_at,
        modified_by
    FROM source
)

SELECT *
FROM renamed
