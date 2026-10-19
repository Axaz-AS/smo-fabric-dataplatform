/*
    Model: core_ops__nav_decision
    Domain: Operations (Ops)
    Grain: 1 row per conformed vedtak decision (pk_nav_decision_id)

    Business Logic:
    - Conformed NAV decision entity unifying legacy statvedtak records with
      exp_vedtak master-export records via int_ops__nav_decision_unified.
    - Join rationale: full-export validation proved statvedtak.fk_vedtak_id
      matches exp_vedtak.pk_exp_vedtak_id 1-to-1, so the conformed vedtak key
      itself is the primary key pk_nav_decision_id. source_origin +
      source_record_id preserve per-source provenance.
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
    CAST(u.pk_nav_decision_id AS VARCHAR(64))             AS pk_nav_decision_id,
    CAST(u.source_origin AS VARCHAR(50))                  AS source_origin,
    CAST(u.source_record_id AS VARCHAR(64))               AS source_record_id,
    CAST(u.fk_patient AS VARCHAR(64))                     AS fk_patient,
    CAST(u.fk_order AS VARCHAR(64))                       AS fk_order,
    CAST(u.fk_vedtak_id AS VARCHAR(64))                   AS fk_vedtak_id,
    CAST(u.patient_number AS VARCHAR(50))                 AS patient_number,
    CAST(u.fk_avdeling_id AS VARCHAR(64))                 AS fk_avdeling_id,
    CAST(u.fk_nomenclature AS VARCHAR(64))                AS fk_nomenclature,
    CAST(u.decision_status AS VARCHAR(100))               AS decision_status,
    CAST(u.decision_type AS VARCHAR(100))                 AS decision_type,
    TRY_CAST(u.date_decision AS DATE)                     AS date_decision,
    TRY_CAST(u.date_sent_nav AS DATE)                     AS date_sent_nav,
    CAST(u.fk_vedtak_type_code AS VARCHAR(50))            AS fk_vedtak_type_code,
    CAST(u.decision_name AS VARCHAR(255))                 AS decision_name,
    CAST(u.decision_icd10_code AS VARCHAR(50))            AS decision_icd10_code,
    TRY_CAST(u.decision_extension_expiration_date AS DATE) AS decision_extension_expiration_date,
    TRY_CAST(u.renewal_expiration_date AS DATE)           AS renewal_expiration_date,
    CAST(u.renewal_status_text AS VARCHAR(100))           AS renewal_status_text,
    CAST(u.renewal_status_code AS VARCHAR(50))            AS renewal_status_code,
    TRY_CAST(u.created_at AS DATETIME2(6))                AS created_at,
    CAST(u.created_by AS VARCHAR(100))                    AS created_by,
    TRY_CAST(u.modified_at AS DATETIME2(6))               AS modified_at,
    CAST(u.modified_by AS VARCHAR(100))                   AS modified_by
FROM unified u
INNER JOIN patients p
    ON u.fk_patient = p.pk_patient_id
