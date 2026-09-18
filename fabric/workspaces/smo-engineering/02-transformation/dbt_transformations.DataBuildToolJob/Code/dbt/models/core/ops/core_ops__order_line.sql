/*
    Model: core_ops__order_line
    Domain: Operations (Ops)
    Grain: 1 row per order line (pk_order_line_id)

    Business Logic:
    - Conformed core entity for individual component / article lines belonging to a
      clinical or manufacturing order: article numbers and designations, supplier info,
      quantities, prices and per-line nomenclature code.
    - Sourced from base_nobs__statordrelinje.
    - Supports LOP mapping of "component history / model warehouse / order lines"
      (article number, designation, amount, price).
    - fk_order references core_ops__order. parent_order_line_id, component_id and
      supplier_id are kept as plain IDs because no parent line, component or
      supplier core entity exists yet.
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__statordrelinje') }}
),

renamed AS (
    SELECT
        pk_ordrelinje_id                                AS pk_order_line_id,
        fk_ordre_id                                     AS fk_order,
        fk_parent_ordrelinje_id                         AS parent_order_line_id,
        fk_komponent_id                                 AS component_id,
        fk_leverandoer_id                               AS supplier_id,
        fk_avdeling_id,
        fk_sted_id,

        -- Classification & status
        order_number,
        status                                          AS line_status,
        production_status,
        nomenclature_code,
        destination_code,

        -- Quantities
        quantity_ordered,
        quantity_picked,

        -- Article / component identification
        article_number_internal,
        article_number_supplier,
        article_name_internal,
        article_name_supplier,

        -- Supplier
        supplier_number,
        supplier_admin_number,
        supplier_name,

        -- Prices & amounts
        unit_price,
        unit_price_in,
        unit_price_out,
        line_amount,
        line_amount_picked_in,
        line_amount_picked_out,

        -- Invoicing
        invoice_number,
        copay_invoice_number,

        -- Key business dates
        order_date,
        registered_date,
        ordered_from_supplier_date,
        picked_date,
        invoice_date,
        copay_invoice_date,

        -- Organizational attributes
        department_name,
        location_name,

        -- Audit & origin
        is_locked,
        created_at,
        created_by,
        modified_at,
        modified_by
    FROM source
)

SELECT *
FROM renamed
