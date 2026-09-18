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
        d.pk_diagnose_id                                    AS pk_diagnosis_id,
        d.fk_person_id                                      AS fk_patient,
        d.fk_type_code                                      AS diagnosis_type_code,
        d.diagnosis,
        d.diagnosis_display,
        d.clinical_aid_type,
        d.clinical_info_line,
        d.clinical_injury_level,
        d.clinical_injury_side,
        d.clinical_injury_type,
        d.clinical_wound,
        d.clinical_wound_location,
        d.clinical_wound_location_date,
        d.clinical_occupational_injury,
        d.created_at,
        d.created_by,
        d.modified_at,
        d.modified_by
    FROM source d
    INNER JOIN patients p
        ON d.fk_person_id = p.pk_patient_id
)

SELECT *
FROM diagnoses
