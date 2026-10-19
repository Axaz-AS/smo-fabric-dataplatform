/*
    Model: core_ops__patient_contact
    Domain: Operations (Ops)
    Grain: 1 row per contact channel per patient (pk_patient_contact_id)

    Business Logic:
    - Normalized 1:N contact methods (mobile, phone, private/work email) per patient.
    - Sourced from exp_kontakt and filtered to persons present in core_ops__patient.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_kontakt') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
),

patient_contacts AS (
    SELECT
        CAST(c.pk_kontakt_id AS VARCHAR(64))                AS pk_patient_contact_id,
        CAST(c.fk_person_id AS VARCHAR(64))                 AS fk_patient,
        CAST(c.contact_type AS VARCHAR(50))                 AS contact_type,
        CAST(c.contact_value AS VARCHAR(255))               AS contact_value,
        CAST(c.is_sms AS BIT)                               AS is_sms_enabled,
        TRY_CAST(c.created_at AS DATETIME2(6))              AS created_at,
        CAST(c.created_by AS VARCHAR(100))                  AS created_by,
        TRY_CAST(c.modified_at AS DATETIME2(6))             AS modified_at,
        CAST(c.modified_by AS VARCHAR(100))                 AS modified_by
    FROM source c
    INNER JOIN patients p
        ON c.fk_person_id = p.pk_patient_id
)

SELECT *
FROM patient_contacts
