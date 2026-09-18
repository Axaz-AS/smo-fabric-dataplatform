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
        j.pk_journal_id                                     AS pk_journal_id,
        j.fk_person_id                                      AS fk_patient,
        j.fk_ordre_id                                       AS fk_order,
        j.journal_date,
        j.epj_document_type,
        j.case_type,
        j.journal_text,
        j.created_by_user,
        j.created_at,
        j.created_by,
        j.modified_at,
        j.modified_by
    FROM source j
    INNER JOIN patients p
        ON j.fk_person_id = p.pk_patient_id
)

SELECT *
FROM journal_entries
