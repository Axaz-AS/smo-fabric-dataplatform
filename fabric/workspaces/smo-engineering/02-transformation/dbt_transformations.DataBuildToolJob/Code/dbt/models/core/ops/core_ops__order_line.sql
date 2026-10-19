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
        CAST(pk_ordrelinje_id AS VARCHAR(64))           AS pk_order_line_id,
        CAST(fk_ordre_id AS VARCHAR(64))                AS fk_order,
        CAST(fk_parent_ordrelinje_id AS VARCHAR(64))    AS parent_order_line_id,
        CAST(fk_komponent_id AS VARCHAR(64))            AS component_id,
        CAST(fk_leverandoer_id AS VARCHAR(64))          AS supplier_id,
        CAST(fk_avdeling_id AS VARCHAR(64))             AS fk_avdeling_id,
        CAST(fk_sted_id AS VARCHAR(64))                 AS fk_sted_id,

        -- Classification & status
        CAST(order_number AS VARCHAR(50))               AS order_number,
        CAST(status AS VARCHAR(50))                     AS line_status,
        CAST(production_status AS VARCHAR(50))          AS production_status,
        CAST(nomenclature_code AS VARCHAR(50))          AS nomenclature_code,
        CAST(destination_code AS VARCHAR(50))           AS destination_code,

        -- Quantities
        TRY_CAST(quantity_ordered AS FLOAT)             AS quantity_ordered,
        TRY_CAST(quantity_picked AS FLOAT)              AS quantity_picked,

        -- Article / component identification
        CAST(article_number_internal AS VARCHAR(50))    AS article_number_internal,
        CAST(article_number_supplier AS VARCHAR(50))    AS article_number_supplier,
        CAST(article_name_internal AS VARCHAR(255))     AS article_name_internal,
        CAST(article_name_supplier AS VARCHAR(255))     AS article_name_supplier,

        -- Supplier
        CAST(supplier_number AS VARCHAR(50))            AS supplier_number,
        CAST(supplier_admin_number AS VARCHAR(50))      AS supplier_admin_number,
        CAST(supplier_name AS VARCHAR(255))             AS supplier_name,

        -- Prices & amounts
        TRY_CAST(unit_price AS FLOAT)                   AS unit_price,
        TRY_CAST(unit_price_in AS FLOAT)                AS unit_price_in,
        TRY_CAST(unit_price_out AS FLOAT)               AS unit_price_out,
        TRY_CAST(line_amount AS FLOAT)                  AS line_amount,
        TRY_CAST(line_amount_picked_in AS FLOAT)        AS line_amount_picked_in,
        TRY_CAST(line_amount_picked_out AS FLOAT)       AS line_amount_picked_out,

        -- Invoicing
        CAST(invoice_number AS VARCHAR(50))             AS invoice_number,
        CAST(copay_invoice_number AS VARCHAR(50))       AS copay_invoice_number,

        -- Key business dates
        TRY_CAST(order_date AS DATE)                    AS order_date,
        TRY_CAST(registered_date AS DATE)               AS registered_date,
        TRY_CAST(ordered_from_supplier_date AS DATE)    AS ordered_from_supplier_date,
        TRY_CAST(picked_date AS DATE)                   AS picked_date,
        TRY_CAST(invoice_date AS DATE)                  AS invoice_date,
        TRY_CAST(copay_invoice_date AS DATE)            AS copay_invoice_date,

        -- Organizational attributes
        CAST(department_name AS VARCHAR(100))           AS department_name,
        CAST(location_name AS VARCHAR(100))             AS location_name,

        -- Audit & origin
        CAST(is_locked AS BIT)                          AS is_locked,
        TRY_CAST(created_at AS DATETIME2(6))            AS created_at,
        CAST(created_by AS VARCHAR(100))                AS created_by,
        TRY_CAST(modified_at AS DATETIME2(6))           AS modified_at,
        CAST(modified_by AS VARCHAR(100))               AS modified_by
    FROM source
)

SELECT *
FROM renamed
