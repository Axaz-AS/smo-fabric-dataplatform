/*
    Model: fct_ops_lop_order
    Domain: Operations (Ops) — Consumer: LOP (Sophies Minde migration import)
    Grain: 1 row per clinical / manufacturing order (pk_order_id)

    Business Logic:
    - Order fact for the LOP migration import data product. LOP fetches orders
      as JSON from the datalake; this table is the source of that export.
    - Field selection follows the NOBS-to-LOP mapping workbook: order number,
      order date, order type, status and patient reference, plus the role-based
      references LOP needs on the patient card (engineer, requisitioning
      physician) and the primary nomenclature of the device.
    - Invoicing fields (invoice date, invoice number, amounts, copay) are
      intentionally excluded: invoicing is not migrated to LOP.
    - order_status carries ~40 Norwegian workflow statuses from NOBS; a
      status-mapping to LOP order statuses must be agreed before import.
    - order_type carries source codes (N / R / K); code-to-name mapping must be
      agreed with the business.
    - Draft scope: built on the full legacy order population (stat_statistikk);
      enriched via core_ops__order with exp_ordre master-export references
      (fk_assistive_device, fk_nav_decision) and trial/completion dates.
    - Scoped to the conformed patient population (inner join core_ops__patient):
      ~1.8% of legacy orders cannot be linked to a patient (14 with no patient
      reference, 1,694 pointing at patients outside core_ops__patient) and are
      excluded — LOP orders must attach to an imported patient. Counts to be
      re-verified when the full NOBS export arrives.
*/

WITH orders AS (
    SELECT * FROM {{ ref('core_ops__order') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
)

SELECT
    o.pk_order_id,
    o.order_number,

    -- Patient and practitioner references for the LOP patient card
    o.fk_patient,
    o.patient_number,
    o.fk_employee_engineer,
    o.fk_employee_production_manager,
    o.fk_health_personnel_rekvirent,
    o.fk_primary_nomenclature,
    o.fk_assistive_device,
    o.fk_nav_decision,

    -- Organizational attributes
    o.department_name,
    o.location_name,

    -- Classification & status (LOP: order type + production/order status)
    o.order_type,
    o.order_status,
    o.is_in_production,
    o.is_urgent,
    o.is_cancelled,

    -- Key business dates (LOP: order date)
    o.order_date,
    o.planned_delivery_date,
    o.delivery_date,
    o.trial_date,
    o.completed_date,

    -- Audit & origin
    o.source_origin,
    o.created_at,
    o.modified_at
FROM orders o
INNER JOIN patients p
    ON o.fk_patient = p.pk_patient_id
