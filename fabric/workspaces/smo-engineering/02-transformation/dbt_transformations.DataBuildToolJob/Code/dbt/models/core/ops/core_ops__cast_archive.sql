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
        g.pk_gipslager_id                                   AS pk_cast_archive_id,
        g.fk_person_id                                      AS fk_patient,
        g.category                                          AS cast_category,
        g.location                                          AS cast_location,
        g.order_number,
        g.date_to_storage,
        g.date_discard,
        g.created_at,
        g.created_by,
        g.modified_at,
        g.modified_by
    FROM source g
    INNER JOIN patients p
        ON g.fk_person_id = p.pk_patient_id
)

SELECT *
FROM cast_archive_items
