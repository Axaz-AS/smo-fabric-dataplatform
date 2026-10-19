/*
    Model: int_ops__nav_decision_unified
    Domain: Operations (Ops)
    Grain: 1 row per conformed vedtak (decision) record

    Business Logic & Assumptions:
    - Unifies NAV decision (vedtak) records from the legacy statvedtak table and
      the new exp_vedtak master export into one conformed stream.
    - Full-export validation: statvedtak.fk_vedtak_id matches
      exp_vedtak.pk_exp_vedtak_id 1-to-1 (202,568 of 202,569 rows), so the two
      sources are united by FULL OUTER JOIN on that shared vedtak key — not a
      UNION ALL — giving one row per real-world decision. source_origin keeps
      provenance ('statvedtak', 'exp_vedtak' or 'statvedtak+exp_vedtak').
    - Columns present in both sources are coalesced (exp_vedtak preferred where
      it is the master export); source-exclusive columns pass through as-is.
*/

WITH vedtak_stat AS (
    SELECT * FROM {{ ref('base_nobs__statvedtak') }}
),

vedtak_exp AS (
    SELECT * FROM {{ ref('base_nobs__exp_vedtak') }}
),

unified AS (
    SELECT
        COALESCE(s.fk_vedtak_id, e.pk_exp_vedtak_id)       AS pk_nav_decision_id,
        CASE
            WHEN s.fk_vedtak_id IS NOT NULL AND e.pk_exp_vedtak_id IS NOT NULL THEN 'statvedtak+exp_vedtak'
            WHEN s.fk_vedtak_id IS NOT NULL THEN 'statvedtak'
            ELSE 'exp_vedtak'
        END                                                AS source_origin,
        COALESCE(s.pk_stat_vedtak_id, e.pk_exp_vedtak_id)  AS source_record_id,
        COALESCE(e.fk_person_id, s.fk_person_id)          AS fk_patient,
        COALESCE(e.fk_ordre_id, s.fk_ordre_id)            AS fk_order,
        COALESCE(s.fk_vedtak_id, e.pk_exp_vedtak_id)       AS fk_vedtak_id,
        s.patient_number,
        s.fk_avdeling_id,
        s.nomenclature_code                                AS fk_nomenclature,
        s.status                                           AS decision_status,
        s.calc_type                                        AS decision_type,
        s.date_decision,
        s.date_sent_nav,
        e.fk_vedtak_type_code,
        e.decision_name,
        e.decision_icd10_code,
        e.decision_extension_expiration_date,
        e.renewal_expiration_date,
        e.renewal_status_text,
        e.renewal_status_code,
        COALESCE(e.created_at, s.created_at)               AS created_at,
        COALESCE(e.created_by, s.created_by)               AS created_by,
        COALESCE(e.modified_at, s.modified_at)             AS modified_at,
        COALESCE(e.modified_by, s.modified_by)             AS modified_by
    FROM vedtak_stat s
    FULL OUTER JOIN vedtak_exp e
        ON s.fk_vedtak_id = e.pk_exp_vedtak_id
)

SELECT *
FROM unified
