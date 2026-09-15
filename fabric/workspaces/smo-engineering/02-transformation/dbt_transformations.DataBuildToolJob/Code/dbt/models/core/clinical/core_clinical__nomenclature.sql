/*
    Model: core_clinical__nomenclature
    Domain: Clinical
    Grain: 1 row per nomenclature code (pk_nomenclature_code)

    Business Logic:
    - Master conformed catalog of orthopedic aid nomenclature codes (ISPO / NAV standard classification).
    - Unifies and cleans reference data from official NAV mappings (excel_mappings.nomenklatur)
      and NOBS product definitions (statnomenklatur_detail).
*/

WITH unified AS (
    SELECT * FROM {{ ref('int_clinical__nomenclature_unified') }}
)

SELECT
    pk_nomenclature_code,
    nobs_detail_id,
    nomenclature_category_code,
    subject_area,
    product_group,
    product_sub_group,
    description,
    has_additional_codes,
    price_group,
    order_type,
    source_origin
FROM unified
