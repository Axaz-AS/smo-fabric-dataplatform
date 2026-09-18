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
        c.pk_kontakt_id                                     AS pk_patient_contact_id,
        c.fk_person_id                                      AS fk_patient,
        c.contact_type,
        c.contact_value,
        c.is_sms                                            AS is_sms_enabled,
        c.created_at,
        c.created_by,
        c.modified_at,
        c.modified_by
    FROM source c
    INNER JOIN patients p
        ON c.fk_person_id = p.pk_patient_id
)

SELECT *
FROM patient_contacts
