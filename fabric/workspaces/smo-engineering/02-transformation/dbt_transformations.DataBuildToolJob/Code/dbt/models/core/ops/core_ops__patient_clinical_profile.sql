/*
    Model: core_ops__patient_clinical_profile
    Domain: Operations (Ops)
    Grain: 1 row per patient clinical profile (pk_patient_clinical_profile_id)

    Business Logic:
    - Normalized 1:1 clinical metrics, treatment risk assessments, and behavioral/communication
      notes for patients.
    - Sourced from exp_personalia and strictly linked to core_ops__patient.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_personalia') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
),

clinical_profile AS (
    SELECT
        CAST(p.pk_personalia_id AS VARCHAR(64))            AS pk_patient_clinical_profile_id,
        CAST(p.fk_person_id AS VARCHAR(64))                AS fk_patient,
        CAST(p.clinical_activity_level AS VARCHAR(100))    AS clinical_activity_level,
        CAST(p.clinical_treatment_risk AS VARCHAR(100))    AS clinical_treatment_risk,
        TRY_CAST(p.clinical_height_cm AS INT)              AS clinical_height_cm,
        TRY_CAST(p.clinical_weight_kg AS INT)               AS clinical_weight_kg,
        CAST(p.clinical_communication_needs AS VARCHAR(255)) AS clinical_communication_needs,
        CAST(p.clinical_special_observations AS VARCHAR(MAX)) AS clinical_special_observations,
        CAST(p.communication_needs AS VARCHAR(255))        AS communication_needs,
        CAST(p.followup_method AS VARCHAR(100))             AS followup_method,
        CAST(p.attendance_needs AS VARCHAR(100))            AS attendance_needs,
        CAST(p.bht_fastlege AS VARCHAR(1000))              AS bht_fastlege_notes,
        CAST(p.bht_fysioterapeut AS VARCHAR(1000))         AS bht_fysioterapeut_notes,
        CAST(p.bht_ergoterapeut AS VARCHAR(1000))          AS bht_ergoterapeut_notes,
        CAST(p.bht_ingenior AS VARCHAR(1000))              AS bht_ingenior_notes,
        CAST(p.bht_koordinerende_behandler AS VARCHAR(1000)) AS bht_koordinerende_behandler_notes,
        CAST(p.bht_rekvirent AS VARCHAR(1000))             AS bht_rekvirent_notes,
        TRY_CAST(p.created_at AS DATETIME2(6))              AS created_at,
        CAST(p.created_by AS VARCHAR(100))                  AS created_by,
        TRY_CAST(p.modified_at AS DATETIME2(6))             AS modified_at,
        CAST(p.modified_by AS VARCHAR(100))                 AS modified_by
    FROM source p
    INNER JOIN patients pat
        ON p.fk_person_id = pat.pk_patient_id
)

SELECT *
FROM clinical_profile
