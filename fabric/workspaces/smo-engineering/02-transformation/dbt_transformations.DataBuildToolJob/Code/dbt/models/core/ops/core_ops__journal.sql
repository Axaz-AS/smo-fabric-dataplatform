/*
    Model: core_ops__journal
    Domain: Operations (Ops)
    Grain: 1 row per journal entry (pk_journal_id)

    Business Logic:
    - Conformed NOBS journal entries (EPJ journaltekster) linked to patients and orders.
    - Sourced from exp_journal and scoped strictly to patients present in core_ops__patient.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_journal') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
),

journal_entries AS (
    SELECT
        CAST(j.pk_journal_id AS VARCHAR(64))                AS pk_journal_id,
        CAST(j.fk_person_id AS VARCHAR(64))                 AS fk_patient,
        CAST(j.fk_ordre_id AS VARCHAR(64))                  AS fk_order,
        TRY_CAST(j.journal_date AS DATE)                    AS journal_date,
        CAST(j.epj_document_type AS VARCHAR(100))          AS epj_document_type,
        CAST(j.case_type AS VARCHAR(100))                   AS case_type,
        CAST(j.journal_text AS VARCHAR(MAX))                AS journal_text,
        CAST(j.created_by_user AS VARCHAR(100))             AS created_by_user,
        TRY_CAST(j.created_at AS DATETIME2(6))              AS created_at,
        CAST(j.created_by AS VARCHAR(100))                  AS created_by,
        TRY_CAST(j.modified_at AS DATETIME2(6))             AS modified_at,
        CAST(j.modified_by AS VARCHAR(100))                 AS modified_by
    FROM source j
    INNER JOIN patients p
        ON j.fk_person_id = p.pk_patient_id
)

SELECT *
FROM journal_entries
