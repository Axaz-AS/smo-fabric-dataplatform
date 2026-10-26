create view [int].[int_ops__order_line_unified] as /*
    Model: int_ops__order_line_unified
    Domain: Operations (Ops)
    Grain: 1 row per exp_ordrelinje order line, augmented by statordrelinje where the line matches

    Business Logic & Assumptions:
    - Unifies order lines from the exp_ordrelinje master export (driving, precedence)
      and the legacy statordrelinje table (augmenting).
    - exp_ordrelinje is the system-of-record export: 751,804 lines across 209,333 orders.
      statordrelinje is a subset: 109,303 lines across 53,216 orders, 99.4% of which are
      present in exp. Within the shared orders the two tables carry the same ~109k lines.
    - The line PKs (__kplt_ID) are fully disjoint, so the sources are matched on the
      natural line key (order, component, article, quantity, unit price) — validated
      99.5-99.9% exact match within shared orders (2026-10-20).
    - statordrelinje is de-duplicated to one line per natural key before the join to
      prevent fan-out (16% of stat lines share a key; 99.5% of those carry identical
      stat-only attributes, so keeping the most recently modified line is safe).
    - exp_ordrelinje drives via LEFT JOIN: every exp line is preserved. Shared columns
      coalesce exp-first (exp precedence, stat fills exp NULLs); exp-only and stat-only
      columns pass through. source_origin keeps provenance.
    - ~642k exp lines (156k orders) have no stat counterpart and carry NULL stat fields.
*/

WITH exp_lines AS (
    SELECT * FROM [wh_silver].[int].[base_nobs__exp_ordrelinje]
),

stat_lines AS (
    SELECT * FROM [wh_silver].[int].[base_nobs__statordrelinje]
),

-- One stat line per natural key (most recently modified wins) to avoid join fan-out
stat_dedup AS (
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY fk_ordre_id, fk_komponent_id, article_number_internal, quantity_ordered, unit_price
                ORDER BY modified_at DESC, pk_ordrelinje_id
            ) AS _stat_rn
        FROM stat_lines
    ) t
    WHERE _stat_rn = 1
),

unified AS (
    SELECT
        e.pk_ordrelinje_id                                   AS pk_ordrelinje_id,
        CASE
            WHEN s.pk_ordrelinje_id IS NOT NULL THEN 'exp_ordrelinje+statordrelinje'
            ELSE 'exp_ordrelinje'
        END                                                  AS source_origin,

        -- Keys (exp drives)
        e.fk_ordre_id                                        AS fk_ordre_id,
        e.fk_komponent_id                                    AS fk_komponent_id,
        e.fk_person_id                                       AS fk_person_id,

        -- Shared columns: exp precedence, stat fills exp NULLs
        COALESCE(e.status, s.status)                         AS status,
        COALESCE(e.quantity_ordered, s.quantity_ordered)     AS quantity_ordered,
        COALESCE(e.quantity_picked, s.quantity_picked)       AS quantity_picked,
        COALESCE(e.article_number_internal, s.article_number_internal) AS article_number_internal,
        COALESCE(e.article_number_supplier, s.article_number_supplier) AS article_number_supplier,
        COALESCE(e.article_name_internal, s.article_name_internal)     AS article_name_internal,
        COALESCE(e.article_name_supplier, s.article_name_supplier)     AS article_name_supplier,
        COALESCE(e.department_name, s.department_name)       AS department_name,
        COALESCE(e.destination_code, s.destination_code)     AS destination_code,
        COALESCE(e.unit_price, s.unit_price)                 AS unit_price,
        COALESCE(e.line_amount, s.line_amount)               AS line_amount,
        COALESCE(e.ordered_from_supplier_date, s.ordered_from_supplier_date) AS ordered_from_supplier_date,
        COALESCE(e.copay_invoice_date, s.copay_invoice_date) AS copay_invoice_date,
        COALESCE(e.copay_invoice_number, s.copay_invoice_number) AS copay_invoice_number,
        COALESCE(e.is_locked, s.is_locked)                   AS is_locked,
        COALESCE(e.created_at, s.created_at)                 AS created_at,
        COALESCE(e.created_by, s.created_by)                 AS created_by,
        COALESCE(e.modified_at, s.modified_at)               AS modified_at,
        COALESCE(e.modified_by, s.modified_by)               AS modified_by,

        -- exp-only columns
        e.quantity_loaned                                    AS quantity_loaned,
        e.quantity_available_for_reservation                 AS quantity_available_for_reservation,
        e.batch_number_supplier                              AS batch_number_supplier,
        e.unit                                               AS unit,
        e.component_category                                 AS component_category,
        e.reference                                          AS reference,
        e.serial_number                                      AS serial_number,

        -- stat-only columns (NULL for exp-only lines)
        s.fk_parent_ordrelinje_id                            AS fk_parent_ordrelinje_id,
        s.fk_leverandoer_id                                  AS fk_leverandoer_id,
        s.fk_avdeling_id                                     AS fk_avdeling_id,
        s.fk_sted_id                                         AS fk_sted_id,
        s.order_number                                       AS order_number,
        s.production_status                                  AS production_status,
        s.nomenclature_code                                  AS nomenclature_code,
        s.supplier_number                                    AS supplier_number,
        s.supplier_admin_number                              AS supplier_admin_number,
        s.supplier_name                                      AS supplier_name,
        s.unit_price_in                                      AS unit_price_in,
        s.unit_price_out                                     AS unit_price_out,
        s.line_amount_picked_in                              AS line_amount_picked_in,
        s.line_amount_picked_out                             AS line_amount_picked_out,
        s.invoice_number                                     AS invoice_number,
        s.order_date                                         AS order_date,
        s.registered_date                                    AS registered_date,
        s.picked_date                                        AS picked_date,
        s.invoice_date                                       AS invoice_date,
        s.location_name                                      AS location_name
    FROM exp_lines e
    LEFT JOIN stat_dedup s
        ON  e.fk_ordre_id             = s.fk_ordre_id
        AND e.fk_komponent_id         = s.fk_komponent_id
        AND e.article_number_internal = s.article_number_internal
        AND e.quantity_ordered        = s.quantity_ordered
        AND e.unit_price              = s.unit_price
)

SELECT *
FROM unified;

GO