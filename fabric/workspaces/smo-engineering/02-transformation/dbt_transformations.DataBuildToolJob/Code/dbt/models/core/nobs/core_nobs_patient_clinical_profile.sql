/*
    Model: core_nobs_patient_clinical_profile
    Domain: NOBS
    Grain: 1 row per patient clinical profile (pk_patient_clinical_profile_id)

    Business Logic:
    - Normalized 1:1 clinical metrics, treatment risk assessments, and behavioral/communication
      notes for patients.
    - Sourced from exp_personalia and strictly linked to core_nobs_patient.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__personalia') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_nobs_patient') }}
),

clinical_profile AS (
    SELECT
        p.pk_personalia_id                                 AS pk_patient_clinical_profile_id,
        p.fk_person_id                                     AS fk_patient,
        p.clinical_activity_level,
        p.clinical_treatment_risk,
        p.clinical_height_cm,
        p.clinical_weight_kg,
        p.clinical_communication_needs,
        p.clinical_special_observations,
        p.communication_needs,
        p.followup_method,
        p.attendance_needs,
        p.bht_fastlege                                     AS bht_fastlege_notes,
        p.bht_fysioterapeut                                AS bht_fysioterapeut_notes,
        p.bht_ergoterapeut                                 AS bht_ergoterapeut_notes,
        p.bht_ingenior                                     AS bht_ingenior_notes,
        p.bht_koordinerende_behandler                      AS bht_koordinerende_behandler_notes,
        p.bht_rekvirent                                    AS bht_rekvirent_notes,
        p.created_at,
        p.created_by,
        p.modified_at,
        p.modified_by
    FROM source p
    INNER JOIN patients pat
        ON p.fk_person_id = pat.pk_patient_id
)

SELECT *
FROM clinical_profile
