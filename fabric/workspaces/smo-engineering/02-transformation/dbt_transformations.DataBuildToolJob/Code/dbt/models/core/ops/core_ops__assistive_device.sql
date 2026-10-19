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
        CAST(h.pk_hjelpemiddel_id AS VARCHAR(64))           AS pk_assistive_device_id,
        CAST(h.fk_person_id AS VARCHAR(64))                 AS fk_patient,
        CAST(h.fk_vedtak_id AS VARCHAR(64))                 AS fk_nav_decision,
        CAST(h.fk_vedtak_id AS VARCHAR(64))                 AS vedtak_id,
        CAST(h.fk_fag_code AS VARCHAR(50))                  AS fag_code,
        CAST(h.fk_produksjonsmetode_code AS VARCHAR(50))    AS production_method_code,
        CAST(h.name AS VARCHAR(255))                        AS name,
        CAST(h.icd10_code AS VARCHAR(50))                   AS icd10_code,
        CAST(h.icd10_description AS VARCHAR(255))          AS icd10_description,
        CAST(h.nomenclature_main_group_code AS VARCHAR(50)) AS nomenclature_main_group_code,
        CAST(h.nomenclature_main_group_description AS VARCHAR(255)) AS nomenclature_main_group_description,
        CAST(h.nomenclature_product_code AS VARCHAR(50))    AS nomenclature_product_code,
        CAST(h.nomenclature_product_description AS VARCHAR(255)) AS nomenclature_product_description,
        CAST(h.clinical_cause_of_need AS VARCHAR(255))      AS clinical_cause_of_need,
        CAST(h.clinical_injury_level AS VARCHAR(100))       AS clinical_injury_level,
        CAST(h.clinical_injury_type AS VARCHAR(100))        AS clinical_injury_type,
        CAST(h.clinical_injury_side AS VARCHAR(50))         AS clinical_injury_side,
        CAST(h.clinical_occupational_injury AS VARCHAR(50)) AS clinical_occupational_injury,
        TRY_CAST(h.created_at AS DATETIME2(6))              AS created_at,
        CAST(h.created_by AS VARCHAR(100))                  AS created_by,
        TRY_CAST(h.modified_at AS DATETIME2(6))             AS modified_at,
        CAST(h.modified_by AS VARCHAR(100))                 AS modified_by
    FROM source h
    INNER JOIN patients p
        ON h.fk_person_id = p.pk_patient_id
)

SELECT *
FROM assistive_devices
