/*
    Model: core_ops__order
    Domain: Operations (Ops)
    Grain: 1 row per clinical / manufacturing order (pk_order_id / order_number)

    Business Logic:
    - Master conformed operational order dimension/entity representing custom orthopedic device orders.
    - Sourced from int_ops__order_unified.
    - Contains normalized role-based foreign keys to patient, engineer, production manager,
      requisitioning physician, and primary assistive device nomenclature code.
*/

WITH unified AS (
    SELECT * FROM {{ ref('int_ops__order_unified') }}
)

SELECT
    CAST(pk_order_id AS VARCHAR(64))                      AS pk_order_id,
    CAST(order_number AS VARCHAR(50))                     AS order_number,

    -- Role-based foreign keys
    CAST(fk_patient AS VARCHAR(64))                       AS fk_patient,
    CAST(patient_number AS VARCHAR(50))                   AS patient_number,
    CAST(fk_employee_engineer AS VARCHAR(64))             AS fk_employee_engineer,
    CAST(fk_employee_production_manager AS VARCHAR(64))    AS fk_employee_production_manager,
    CAST(fk_health_personnel_rekvirent AS VARCHAR(64))    AS fk_health_personnel_rekvirent,
    CAST(fk_primary_nomenclature AS VARCHAR(64))         AS fk_primary_nomenclature,

    -- Conformed entity references from exp_ordre
    CAST(fk_assistive_device AS VARCHAR(64))              AS fk_assistive_device,
    CAST(fk_nav_decision AS VARCHAR(64))                  AS fk_nav_decision,

    -- Organizational attributes
    CAST(fk_avdeling_id AS VARCHAR(64))                   AS fk_avdeling_id,
    CAST(department_name AS VARCHAR(100))                 AS department_name,
    CAST(fk_sted_id AS VARCHAR(64))                       AS fk_sted_id,
    CAST(location_name AS VARCHAR(100))                   AS location_name,

    -- Classification & status
    CAST(order_type AS VARCHAR(50))                       AS order_type,
    CAST(order_status AS VARCHAR(100))                    AS order_status,
    CAST(is_urgent AS BIT)                                AS is_urgent,
    CAST(is_cancelled AS BIT)                             AS is_cancelled,
    CAST(is_invoiced AS BIT)                              AS is_invoiced,
    CAST(is_in_production AS BIT)                         AS is_in_production,
    CAST(is_ready_for_invoicing AS BIT)                   AS is_ready_for_invoicing,

    -- Key business dates
    TRY_CAST(order_date AS DATE)                          AS order_date,
    TRY_CAST(planned_delivery_date AS DATE)               AS planned_delivery_date,
    TRY_CAST(delivery_date AS DATE)                       AS delivery_date,
    TRY_CAST(trial_date AS DATE)                          AS trial_date,
    TRY_CAST(completed_date AS DATE)                      AS completed_date,
    TRY_CAST(invoice_date AS DATE)                        AS invoice_date,
    CAST(invoice_number AS VARCHAR(50))                   AS invoice_number,
    TRY_CAST(days_manufacturing AS INT)                   AS days_manufacturing,
    TRY_CAST(days_production AS INT)                      AS days_production,
    TRY_CAST(days_production_hold AS INT)                 AS days_production_hold,

    -- Order detail from exp_ordre
    CAST(delivery_method AS VARCHAR(100))                 AS delivery_method,
    CAST(order_notes AS VARCHAR(4000))                    AS order_notes,
    CAST(trial_notes AS VARCHAR(4000))                    AS trial_notes,
    CAST(delivery_notes AS VARCHAR(4000))                 AS delivery_notes,

    -- Aggregated order quantities and amounts
    TRY_CAST(total_order_items AS INT)                    AS total_order_items,
    TRY_CAST(total_quantity AS FLOAT)                     AS total_quantity,
    TRY_CAST(total_invoice_amount AS FLOAT)               AS total_invoice_amount,
    TRY_CAST(total_copay_amount AS FLOAT)                 AS total_copay_amount,

    -- Audit & origin
    CAST(source_origin AS VARCHAR(20))                    AS source_origin,
    TRY_CAST(created_at AS DATETIME2(6))                  AS created_at,
    TRY_CAST(modified_at AS DATETIME2(6))                 AS modified_at
FROM unified
