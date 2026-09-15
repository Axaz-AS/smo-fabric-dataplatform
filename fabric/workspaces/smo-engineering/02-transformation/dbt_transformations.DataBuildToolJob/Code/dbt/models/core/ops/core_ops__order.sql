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
    pk_order_id,
    order_number,

    -- Role-based foreign keys
    fk_patient,
    patient_number,
    fk_employee_engineer,
    fk_employee_production_manager,
    fk_health_personnel_rekvirent,
    fk_primary_nomenclature,

    -- Organizational attributes
    fk_avdeling_id,
    department_name,
    fk_sted_id,
    location_name,

    -- Classification & status
    order_type,
    order_status,
    is_urgent,
    is_cancelled,
    is_invoiced,
    is_in_production,
    is_ready_for_invoicing,

    -- Key business dates
    order_date,
    planned_delivery_date,
    delivery_date,
    invoice_date,
    days_manufacturing,
    days_production,
    days_production_hold,

    -- Aggregated order quantities and amounts
    total_order_items,
    total_quantity,
    total_invoice_amount,
    total_copay_amount,

    -- Audit & origin
    source_origin,
    created_at,
    modified_at
FROM unified
