create view [int].[int_ops__nav_decision_unified] as /*
    Model: int_ops__nav_decision_unified
    Domain: Operations (Ops)
    Grain: 1 row per decision record from statvedtak or exp_vedtak

    Business Logic & Assumptions:
    - Unifies NAV decision (vedtak) records from the legacy statvedtak table and
      the new exp_vedtak master export into one structurally aligned UNION ALL.
    - The two sources share no vedtak key (statvedtak carries a vedtak header key,
      exp_vedtak only a vedtak type code), so the same real-world decision may
      appear once per source; provenance is kept via source_origin/source_record_id.
    - Branch-specific attributes are NULL-aligned by type in the opposite branch.
*/

WITH vedtak_stat AS (
    SELECT * FROM [wh_silver].[int].[base_nobs__statvedtak]
),

vedtak_exp AS (
    SELECT * FROM [wh_silver].[int].[base_nobs__exp_vedtak]
),

unified AS (
    -- statvedtak branch (legacy NAV decisions)
    SELECT
        'statvedtak'                                       AS source_origin,
        TRY_CAST(s.pk_stat_vedtak_id AS VARCHAR(64))      AS source_record_id,
        s.fk_person_id                                     AS fk_patient,
        s.fk_ordre_id                                      AS fk_order,
        TRY_CAST(s.fk_vedtak_id AS VARCHAR(64))           AS fk_vedtak_id,
        TRY_CAST(s.patient_number AS VARCHAR(50))         AS patient_number,
        TRY_CAST(s.fk_avdeling_id AS VARCHAR(64))         AS fk_avdeling_id,
        TRY_CAST(s.nomenclature_code AS VARCHAR(50))      AS fk_nomenclature,
        TRY_CAST(s.status AS VARCHAR(100))                AS decision_status,
        TRY_CAST(s.calc_type AS VARCHAR(100))             AS decision_type,
        s.date_decision,
        s.date_sent_nav,
        CAST(NULL AS VARCHAR(64))                         AS fk_vedtak_type_code,
        CAST(NULL AS VARCHAR(255))                        AS decision_name,
        CAST(NULL AS VARCHAR(50))                         AS decision_icd10_code,
        CAST(NULL AS DATE)                                 AS decision_extension_expiration_date,
        CAST(NULL AS DATE)                                 AS renewal_expiration_date,
        CAST(NULL AS VARCHAR(255))                        AS renewal_status_text,
        CAST(NULL AS VARCHAR(100))                        AS renewal_status_code,
        s.created_at,
        s.created_by,
        s.modified_at,
        s.modified_by
    FROM vedtak_stat s

    UNION ALL

    -- exp_vedtak branch (new master export decisions)
    SELECT
        'exp_vedtak'                                       AS source_origin,
        TRY_CAST(e.pk_exp_vedtak_id AS VARCHAR(64))       AS source_record_id,
        e.fk_person_id                                     AS fk_patient,
        e.fk_ordre_id                                      AS fk_order,
        CAST(NULL AS VARCHAR(64))                         AS fk_vedtak_id,
        CAST(NULL AS VARCHAR(50))                         AS patient_number,
        CAST(NULL AS VARCHAR(64))                         AS fk_avdeling_id,
        CAST(NULL AS VARCHAR(50))                         AS fk_nomenclature,
        CAST(NULL AS VARCHAR(100))                        AS decision_status,
        CAST(NULL AS VARCHAR(100))                        AS decision_type,
        CAST(NULL AS DATE)                                 AS date_decision,
        CAST(NULL AS DATE)                                 AS date_sent_nav,
        TRY_CAST(e.fk_vedtak_type_code AS VARCHAR(64))    AS fk_vedtak_type_code,
        TRY_CAST(e.decision_name AS VARCHAR(255))         AS decision_name,
        TRY_CAST(e.decision_icd10_code AS VARCHAR(50))    AS decision_icd10_code,
        e.decision_extension_expiration_date,
        e.renewal_expiration_date,
        TRY_CAST(e.renewal_status_text AS VARCHAR(255))   AS renewal_status_text,
        TRY_CAST(e.renewal_status_code AS VARCHAR(100))   AS renewal_status_code,
        e.created_at,
        e.created_by,
        e.modified_at,
        e.modified_by
    FROM vedtak_exp e
)

SELECT *
FROM unified;

GO