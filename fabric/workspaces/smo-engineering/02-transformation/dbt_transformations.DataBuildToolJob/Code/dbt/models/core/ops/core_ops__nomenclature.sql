/*
    Model: core_ops__nomenclature
    Domain: Operations (Ops)
    Grain: 1 row per nomenclature code (pk_nomenclature_code)

    Business Logic:
    - Master conformed catalog of orthopedic aid nomenclature codes (ISPO / NAV standard classification).
    - Unifies and cleans reference data from official NAV mappings (excel_mappings.nomenklatur)
      and NOBS product definitions (statnomenklatur_detail).
*/

WITH unified AS (
    SELECT * FROM {{ ref('int_ops__nomenclature_unified') }}
)

SELECT
    CAST(pk_nomenclature_code AS VARCHAR(64))             AS pk_nomenclature_code,
    CAST(nobs_detail_id AS VARCHAR(64))                   AS nobs_detail_id,
    CAST(nomenclature_category_code AS VARCHAR(50))       AS nomenclature_category_code,
    CAST(subject_area AS VARCHAR(100))                    AS subject_area,
    CAST(product_group AS VARCHAR(255))                   AS product_group,
    CAST(product_sub_group AS VARCHAR(255))               AS product_sub_group,
    CAST(description AS VARCHAR(255))                     AS description,
    CAST(has_additional_codes AS BIT)                     AS has_additional_codes,
    CAST(price_group AS VARCHAR(50))                      AS price_group,
    CAST(order_type AS VARCHAR(50))                       AS order_type,
    CAST(source_origin AS VARCHAR(50))                    AS source_origin
FROM unified
