/*
    Model: core_ops__invoice_line
    Domain: Operations (Ops)
    Grain: 1 row per invoice line (pk_invoice_line_id)

    Business Logic:
    - Conformed core entity for billed line items from the NOBS exp_Fakturalinje
      export: description, quantity, unit price, line amounts (with and without
      VAT), VAT type and posting key per line.
    - Sourced from base_nobs__exp_fakturalinje.
    - fk_invoice_id references core_ops__invoice softly (no relationships test,
      consistent with other NOBS export FKs in this project).
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_fakturalinje') }}
)

SELECT
    CAST(pk_invoice_line_id AS VARCHAR(64))                AS pk_invoice_line_id,
    CAST(fk_invoice_id AS VARCHAR(64))                     AS fk_invoice_id,
    TRY_CAST(quantity AS FLOAT)                            AS quantity,
    CAST(description AS VARCHAR(4000))                     AS description,
    TRY_CAST(unit_price AS FLOAT)                          AS unit_price,
    TRY_CAST(line_amount AS FLOAT)                         AS line_amount,
    TRY_CAST(line_amount_vat AS FLOAT)                     AS line_amount_vat,
    CAST(accounting AS VARCHAR(100))                       AS accounting,
    CAST(vat_type AS VARCHAR(50))                          AS vat_type,
    CAST(line_type AS VARCHAR(50))                         AS line_type,
    TRY_CAST(created_at AS DATETIME2(6))                    AS created_at,
    CAST(created_by AS VARCHAR(100))                       AS created_by,
    TRY_CAST(modified_at AS DATETIME2(6))                   AS modified_at,
    CAST(modified_by AS VARCHAR(100))                      AS modified_by
FROM source
