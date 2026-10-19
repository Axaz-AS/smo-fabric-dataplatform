/*
    Model: core_ops__cast_archive
    Domain: Operations (Ops)
    Grain: 1 row per cast archive (gips- og lestelager) item (pk_cast_archive_id)

    Business Logic:
    - Conformed cast and plaster-cast archive storage records (gips- og lestelager).
    - Sourced from exp_gipslager and scoped strictly to patients present in core_ops__patient.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_gipslager') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
),

cast_archive_items AS (
    SELECT
        CAST(g.pk_gipslager_id AS VARCHAR(64))              AS pk_cast_archive_id,
        CAST(g.fk_person_id AS VARCHAR(64))                 AS fk_patient,
        CAST(g.category AS VARCHAR(100))                    AS cast_category,
        CAST(g.location AS VARCHAR(100))                    AS cast_location,
        CAST(g.order_number AS VARCHAR(50))                 AS order_number,
        TRY_CAST(g.date_to_storage AS DATE)                 AS date_to_storage,
        TRY_CAST(g.date_discard AS DATE)                    AS date_discard,
        TRY_CAST(g.created_at AS DATETIME2(6))              AS created_at,
        CAST(g.created_by AS VARCHAR(100))                  AS created_by,
        TRY_CAST(g.modified_at AS DATETIME2(6))             AS modified_at,
        CAST(g.modified_by AS VARCHAR(100))                 AS modified_by
    FROM source g
    INNER JOIN patients p
        ON g.fk_person_id = p.pk_patient_id
)

SELECT *
FROM cast_archive_items
