/*
    Model: core_ops__invoice_voucher_line
    Domain: Operations (Ops)
    Grain: 1 row per invoice voucher (bilag) line (pk_invoice_voucher_line_id)

    Business Logic:
    - Conformed core entity for invoice attachment / voucher lines from the NOBS
      exp_FakturaBilagslinje export: quantity, internal article designation,
      unit price and line amount per voucher line.
    - Sourced from base_nobs__exp_fakturabilagslinje.
    - fk_invoice_id references core_ops__invoice softly (no relationships test,
      consistent with other NOBS export FKs in this project).
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_fakturabilagslinje') }}
)

SELECT
    CAST(pk_invoice_voucher_line_id AS VARCHAR(64))        AS pk_invoice_voucher_line_id,
    CAST(fk_invoice_id AS VARCHAR(64))                     AS fk_invoice_id,
    TRY_CAST(quantity AS FLOAT)                            AS quantity,
    CAST(article_name_internal AS VARCHAR(255))            AS article_name_internal,
    TRY_CAST(unit_price AS FLOAT)                          AS unit_price,
    TRY_CAST(line_amount AS FLOAT)                         AS line_amount,
    TRY_CAST(created_at AS DATETIME2(6))                    AS created_at,
    CAST(created_by AS VARCHAR(100))                       AS created_by,
    TRY_CAST(modified_at AS DATETIME2(6))                   AS modified_at,
    CAST(modified_by AS VARCHAR(100))                      AS modified_by
FROM source
