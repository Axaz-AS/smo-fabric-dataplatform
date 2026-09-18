/*
    Model: core_ops__nav_decision
    Domain: Operations (Ops)
    Grain: 1 row per NAV decision record per source system (pk_nav_decision_id)

    Business Logic:
    - Conformed NAV decision entity unifying legacy statvedtak records with
      exp_vedtak master-export records via int_ops__nav_decision_unified.
    - Union rationale: the two sources share no vedtak key (no cross-source
      identifier exists), so the same real-world decision may legitimately
      appear once per source. source_origin + source_record_id preserve
      provenance and compose the surrogate key pk_nav_decision_id.
    - Inner join to core_ops__patient scopes decisions to the conformed
      patient population.
*/

WITH unified AS (
    SELECT * FROM {{ ref('int_ops__nav_decision_unified') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
)

SELECT
    CAST(CONCAT(u.source_origin, '|', u.source_record_id) AS VARCHAR(200)) AS pk_nav_decision_id,
    u.source_origin,
    u.source_record_id,
    u.fk_patient,
    u.fk_order,
    u.fk_vedtak_id,
    u.patient_number,
    u.fk_avdeling_id,
    u.fk_nomenclature,
    u.decision_status,
    u.decision_type,
    u.date_decision,
    u.date_sent_nav,
    u.fk_vedtak_type_code,
    u.decision_name,
    u.decision_icd10_code,
    u.decision_extension_expiration_date,
    u.renewal_expiration_date,
    u.renewal_status_text,
    u.renewal_status_code,
    u.created_at,
    u.created_by,
    u.modified_at,
    u.modified_by
FROM unified u
INNER JOIN patients p
    ON u.fk_patient = p.pk_patient_id
