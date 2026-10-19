/*
    Model: core_ops__patient_guardian
    Domain: Operations (Ops)
    Grain: 1 row per guardian per patient (pk_patient_guardian_id)

    Business Logic:
    - Conformed guardian (verge) entity: legal guardians / next of kin registered
      against a patient in NOBS exp_verge.
    - Scoped strictly to patients present in core_ops__patient (inner join),
      so every row carries a resolvable patient reference.
    - Supports LOP mapping of guardian contact details (name, phone, email).
*/

WITH verge AS (
    SELECT * FROM {{ ref('base_nobs__exp_verge') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
)

SELECT
    CAST(v.pk_verge_id AS VARCHAR(64))                     AS pk_patient_guardian_id,
    CAST(v.fk_person_id AS VARCHAR(64))                    AS fk_patient,
    CAST(v.first_name AS VARCHAR(100))                     AS first_name,
    CAST(v.last_name AS VARCHAR(100))                      AS last_name,
    CAST(CASE
        WHEN v.first_name IS NOT NULL OR v.last_name IS NOT NULL
        THEN TRIM(CONCAT(COALESCE(v.first_name, ''), ' ', COALESCE(v.last_name, '')))
        ELSE NULL
    END AS VARCHAR(255))                                   AS full_name,
    CAST(v.phone_number AS VARCHAR(50))                    AS phone_number,
    CAST(v.email AS VARCHAR(255))                          AS email,
    TRY_CAST(v.created_at AS DATETIME2(6))                 AS created_at,
    CAST(v.created_by AS VARCHAR(100))                     AS created_by,
    TRY_CAST(v.modified_at AS DATETIME2(6))                AS modified_at,
    CAST(v.modified_by AS VARCHAR(100))                    AS modified_by
FROM verge v
INNER JOIN patients p
    ON v.fk_person_id = p.pk_patient_id
