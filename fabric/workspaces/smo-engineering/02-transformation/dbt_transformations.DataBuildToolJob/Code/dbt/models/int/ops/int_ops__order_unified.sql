/*
    Model: int_ops__order_unified
    Domain: Operations (Ops)
    Grain: 1 row per clinical / manufacturing order (pk_order_id / order_number)

    Business Logic & Assumptions:
    - Master conformed operational order entity for Sophies Minde.
    - Sourced from base_nobs__stat_statistikk, which records order-level lines and component statistics.
    - Resolves the order header grain (1 row per order_number) by selecting the primary assistive device
      nomenclature code (prioritizing physical devices over 598/599 supplementary service codes).
    - Aggregates total order item count, total quantity, and invoice amounts across all lines.
    - Maps role-based foreign keys to patient, engineer (clinician), production manager,
      requisitioning physician, and primary nomenclature code.
    - Enriched via LEFT JOIN to exp_ordre (NOBS order master export): conformed
      device/decision references (fk_assistive_device, fk_nav_decision), trial and
      completion dates, delivery method and free-text notes; engineer, production
      manager and planned delivery date are coalesced with exp_ordre precedence.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__stat_statistikk') }}
),

exp_orders AS (
    SELECT * FROM {{ ref('base_nobs__exp_ordre') }}
),

ranked_items AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (
            PARTITION BY s.order_number
            ORDER BY
                -- Prioritize physical assistive devices over supplementary/service codes (598%, 599%)
                CASE
                    WHEN s.nomenclature_code IS NOT NULL
                         AND s.nomenclature_code NOT LIKE '598%'
                         AND s.nomenclature_code NOT LIKE '599%'
                    THEN 1
                    WHEN s.nomenclature_code IS NOT NULL THEN 2
                    ELSE 3
                END ASC,
                s.quantity DESC,
                s.invoice_total DESC,
                s.modified_at DESC,
                s.created_at DESC,
                s.pk_statistikk_id DESC
        ) AS rn_primary_item,
        COUNT(*) OVER (PARTITION BY s.order_number) AS total_order_items,
        SUM(COALESCE(s.quantity, 0)) OVER (PARTITION BY s.order_number) AS total_quantity_sum,
        SUM(COALESCE(s.invoice_total, 0)) OVER (PARTITION BY s.order_number) AS total_invoice_amount_sum,
        SUM(COALESCE(s.copay_amount, 0)) OVER (PARTITION BY s.order_number) AS total_copay_amount_sum
    FROM source s
    WHERE s.fk_ordre_id IS NOT NULL
      AND s.order_number IS NOT NULL
),

primary_orders AS (
    SELECT *
    FROM ranked_items
    WHERE rn_primary_item = 1
),

unified AS (
    SELECT
        p.fk_ordre_id                                      AS pk_order_id,
        p.order_number,

        -- Role-based foreign keys
        p.fk_pasient_id                                    AS fk_patient,
        p.patient_number,
        COALESCE(eo.fk_ortopediingenior_id, p.fk_ingenioer_id) AS fk_employee_engineer,
        COALESCE(eo.fk_produksjonsansvarlig_id, p.fk_produksjonsansvarlig_id) AS fk_employee_production_manager,
        p.fk_rekvirent_id                                  AS fk_health_personnel_rekvirent,
        p.nomenclature_code                                AS fk_primary_nomenclature,

        -- Conformed entity references from exp_ordre
        eo.fk_hjelpemiddel_id                              AS fk_assistive_device,
        eo.fk_vedtak_id                                    AS fk_nav_decision,

        -- Organizational references
        p.fk_avdeling_id,
        p.department                                       AS department_name,
        p.fk_sted_id,
        p.location                                         AS location_name,

        -- Order classification & status
        p.calc_order_type                                  AS order_type,
        p.status                                           AS order_status,
        p.is_urgent,
        p.is_cancelled,
        p.is_invoiced,
        p.is_in_production,
        p.is_ready_for_invoicing,

        -- Dates
        p.order_date,
        COALESCE(eo.planned_delivery_date, p.planned_delivery_date) AS planned_delivery_date,
        p.delivery_date,
        eo.trial_date,
        eo.completed_date,
        p.invoice_date,
        p.invoice_number,
        p.days_manufacturing,
        p.days_production,
        p.days_production_hold,

        -- Order detail from exp_ordre (production, delivery and trial notes)
        eo.delivery_method,
        eo.order_notes,
        eo.trial_notes,
        eo.delivery_notes,

        -- Order-level aggregates
        p.total_order_items,
        p.total_quantity_sum                               AS total_quantity,
        p.total_invoice_amount_sum                         AS total_invoice_amount,
        p.total_copay_amount_sum                           AS total_copay_amount,

        -- Metadata
        'stat_statistikk'                                  AS source_origin,
        p.created_at,
        p.created_by,
        p.modified_at,
        p.modified_by
    FROM primary_orders p
    LEFT JOIN exp_orders eo
        ON p.fk_ordre_id = eo.pk_exp_ordre_id
)

SELECT *
FROM unified
