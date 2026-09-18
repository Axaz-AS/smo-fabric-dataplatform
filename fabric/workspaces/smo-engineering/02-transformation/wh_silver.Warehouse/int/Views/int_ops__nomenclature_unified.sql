create view [int].[int_ops__nomenclature_unified] as /*
    Model: int_ops__nomenclature_unified
    Domain: Operations (Ops)
    Grain: 1 row per nomenclature code (pk_nomenclature_code)

    Business Logic & Assumptions:
    - Master conformed nomenclature catalog for orthopedic aids, prosthetics, and orthotics.
    - Sourced from base_excel_mappings__nomenklatur (official NAV / Excel mapping master)
      and base_nobs__statnomenklatur_detail (internal NOBS nomenclature detail).
    - Cleans whitespace and newlines from codes and text.
    - Deduplicates excel mappings where multiple rows existed for the same code (e.g. J/R vs N).
    - Future-proofed to incorporate incoming exp_nomenklatur via this intermediate model.
*/

WITH excel_mapping AS (
    SELECT * FROM [wh_silver].[int].[base_excel_mappings__nomenklatur]
),

nobs_detail AS (
    SELECT * FROM [wh_silver].[int].[base_nobs__statnomenklatur_detail]
),

-- Deduplicate excel mapping by nomenclature_code
excel_dedup AS (
    SELECT
        nomenclature_code,
        nomenclature_category_code,
        subject_area,
        product_group,
        product_sub_group,
        description,
        has_additional_codes,
        price_group,
        ROW_NUMBER() OVER (
            PARTITION BY nomenclature_code 
            ORDER BY 
                CASE WHEN coverage_type = 'J/R' THEN 1 ELSE 2 END,
                description DESC
        ) AS rn
    FROM excel_mapping
),

excel_unique AS (
    SELECT *
    FROM excel_dedup
    WHERE rn = 1
),

-- Clean nobs_detail codes
nobs_clean AS (
    SELECT
        TRIM(REPLACE(REPLACE(REPLACE(product_code, CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) AS product_code,
        pk_nomenklatur_detail_id,
        nomenclature_code,
        product_name,
        product_description,
        order_type
    FROM nobs_detail
    WHERE product_code IS NOT NULL AND product_code <> ''
),

nobs_dedup AS (
    SELECT
        product_code,
        pk_nomenklatur_detail_id,
        nomenclature_code,
        product_name,
        product_description,
        order_type,
        ROW_NUMBER() OVER (
            PARTITION BY product_code 
            ORDER BY pk_nomenklatur_detail_id DESC
        ) AS rn
    FROM nobs_clean
),

nobs_unique AS (
    SELECT *
    FROM nobs_dedup
    WHERE rn = 1
),

all_codes AS (
    SELECT nomenclature_code AS code FROM excel_unique
    UNION
    SELECT product_code AS code FROM nobs_unique
),

unified AS (
    SELECT
        c.code                                              AS pk_nomenclature_code,
        nd.pk_nomenklatur_detail_id                         AS nobs_detail_id,
        COALESCE(em.nomenclature_category_code, nd.nomenclature_code) AS nomenclature_category_code,
        em.subject_area,
        em.product_group,
        em.product_sub_group,
        COALESCE(em.description, nd.product_name, nd.product_description) AS description,
        COALESCE(em.has_additional_codes, 0)                AS has_additional_codes,
        em.price_group,
        nd.order_type,
        CASE
            WHEN em.nomenclature_code IS NOT NULL AND nd.product_code IS NOT NULL THEN 'both'
            WHEN em.nomenclature_code IS NOT NULL THEN 'excel_mappings'
            ELSE 'nobs_detail'
        END                                                AS source_origin
    FROM all_codes c
    LEFT JOIN excel_unique em ON c.code = em.nomenclature_code
    LEFT JOIN nobs_unique nd ON c.code = nd.product_code
)

SELECT *
FROM unified;

GO