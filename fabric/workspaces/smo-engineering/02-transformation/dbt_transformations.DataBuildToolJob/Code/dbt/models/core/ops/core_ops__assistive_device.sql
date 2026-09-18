/*
    Model: core_ops__assistive_device
    Domain: Operations (Ops)
    Grain: 1 row per assistive device / orthopedic aid (pk_assistive_device_id)

    Business Logic:
    - Conformed list of assistive devices / orthopedic aids (hjelpemiddel) a patient has received,
      with nomenclature classification and ICD-10 diagnosis linkage.
    - Sourced from exp_hjelpemiddel and scoped strictly to patients present in core_ops__patient.
    - Supports LOP mapping of orthopedic aids, ICD-10 number/name, device type and injury descriptors.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_hjelpemiddel') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
),

assistive_devices AS (
    SELECT
        h.pk_hjelpemiddel_id                                AS pk_assistive_device_id,
        h.fk_person_id                                      AS fk_patient,
        h.fk_vedtak_id                                      AS vedtak_id,
        h.fk_fag_code                                       AS fag_code,
        h.fk_produksjonsmetode_code                         AS production_method_code,
        h.name,
        h.icd10_code,
        h.icd10_description,
        h.nomenclature_main_group_code,
        h.nomenclature_main_group_description,
        h.nomenclature_product_code,
        h.nomenclature_product_description,
        h.clinical_cause_of_need,
        h.clinical_injury_level,
        h.clinical_injury_type,
        h.clinical_injury_side,
        h.clinical_occupational_injury,
        h.created_at,
        h.created_by,
        h.modified_at,
        h.modified_by
    FROM source h
    INNER JOIN patients p
        ON h.fk_person_id = p.pk_patient_id
)

SELECT *
FROM assistive_devices
