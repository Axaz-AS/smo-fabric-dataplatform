/*
    Model: core_ops__diagnosis
    Domain: Operations (Ops)
    Grain: 1 row per diagnosis record (pk_diagnosis_id)

    Business Logic:
    - Conformed NOBS diagnosis records with clinical descriptors (aids, injury, wound details).
    - Sourced from exp_diagnose and scoped strictly to patients present in core_ops__patient.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_diagnose') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
),

diagnoses AS (
    SELECT
        CAST(d.pk_diagnose_id AS VARCHAR(64))               AS pk_diagnosis_id,
        CAST(d.fk_person_id AS VARCHAR(64))                 AS fk_patient,
        CAST(d.fk_type_code AS VARCHAR(50))                 AS diagnosis_type_code,
        CAST(d.diagnosis AS VARCHAR(255))                   AS diagnosis,
        CAST(d.diagnosis_display AS VARCHAR(255))           AS diagnosis_display,
        CAST(d.clinical_aid_type AS VARCHAR(100))           AS clinical_aid_type,
        CAST(d.clinical_info_line AS VARCHAR(255))          AS clinical_info_line,
        CAST(d.clinical_injury_level AS VARCHAR(100))       AS clinical_injury_level,
        CAST(d.clinical_injury_side AS VARCHAR(50))         AS clinical_injury_side,
        CAST(d.clinical_injury_type AS VARCHAR(100))        AS clinical_injury_type,
        CAST(d.clinical_wound AS VARCHAR(100))              AS clinical_wound,
        CAST(d.clinical_wound_location AS VARCHAR(255))     AS clinical_wound_location,
        TRY_CAST(d.clinical_wound_location_date AS DATE)    AS clinical_wound_location_date,
        CAST(d.clinical_occupational_injury AS VARCHAR(50)) AS clinical_occupational_injury,
        TRY_CAST(d.created_at AS DATETIME2(6))              AS created_at,
        CAST(d.created_by AS VARCHAR(100))                  AS created_by,
        TRY_CAST(d.modified_at AS DATETIME2(6))             AS modified_at,
        CAST(d.modified_by AS VARCHAR(100))                 AS modified_by
    FROM source d
    INNER JOIN patients p
        ON d.fk_person_id = p.pk_patient_id
)

SELECT *
FROM diagnoses
