/*
    Model: core_ops__invoice
    Domain: Operations (Ops)
    Grain: 1 row per invoice / credit note (pk_invoice_id)

    Business Logic:
    - Conformed core entity for invoice headers from the NOBS exp_Faktura export.
    - Top-level financial truth for billed revenue: invoice number and dates,
      totals with and without VAT, payment status, copay and NAV direct-dialog
      amounts, and references to order, billing recipient and subject.
    - Sourced from base_nobs__exp_faktura.
    - fk_order_id / fk_order_number reference core_ops__order softly: the order
      core is scoped to stat_statistikk orders and does not cover every order
      referenced by invoices (same treatment as core_ops__order_line.fk_order).
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_faktura') }}
)

SELECT
    CAST(pk_invoice_id AS VARCHAR(64))                     AS pk_invoice_id,
    CAST(invoice_number AS VARCHAR(50))                    AS invoice_number,
    TRY_CAST(invoice_date AS DATE)                         AS invoice_date,
    TRY_CAST(payment_due_date AS DATE)                     AS payment_due_date,
    TRY_CAST(paid_date AS DATE)                            AS paid_date,
    CAST(invoice_type AS VARCHAR(50))                      AS invoice_type,
    CAST(invoice_kind AS VARCHAR(50))                      AS invoice_kind,
    CAST(invoice_status AS VARCHAR(50))                    AS invoice_status,
    CAST(customer_category AS VARCHAR(50))                 AS customer_category,
    CAST(payment_method AS VARCHAR(50))                    AS payment_method,
    CAST(paid_via AS VARCHAR(50))                          AS paid_via,
    CAST(billing_recipient_private AS VARCHAR(50))         AS billing_recipient_private,
    CAST(billing_customer_name AS VARCHAR(255))            AS billing_customer_name,
    CAST(billing_recipient_id AS VARCHAR(64))              AS billing_recipient_id,
    CAST(department_code AS VARCHAR(50))                   AS department_code,
    CAST(main_department_code AS VARCHAR(50))              AS main_department_code,
    TRY_CAST(total_before_vat AS FLOAT)                    AS total_before_vat,
    TRY_CAST(total_incl_vat AS FLOAT)                      AS total_incl_vat,
    TRY_CAST(vat_amount AS FLOAT)                          AS vat_amount,
    TRY_CAST(outstanding_amount AS FLOAT)                  AS outstanding_amount,
    TRY_CAST(paid_amount AS FLOAT)                         AS paid_amount,
    TRY_CAST(credit_amount AS FLOAT)                       AS credit_amount,
    TRY_CAST(copay_amount AS FLOAT)                        AS copay_amount,
    CAST(copay_indicator AS VARCHAR(50))                   AS copay_indicator,
    TRY_CAST(direct_dialog_amount AS FLOAT)                AS direct_dialog_amount,
    TRY_CAST(direct_dialog_payment_date AS DATE)           AS direct_dialog_payment_date,
    CAST(direct_dialog_accounting AS VARCHAR(100))         AS direct_dialog_accounting,
    CAST(credit_account_number AS VARCHAR(50))             AS credit_account_number,
    CAST(credit_reference AS VARCHAR(100))                 AS credit_reference,
    CAST(requisition_number AS VARCHAR(50))                AS requisition_number,
    CAST(additional_reference AS VARCHAR(100))             AS additional_reference,
    CAST(invoice_note AS VARCHAR(4000))                    AS invoice_note,
    CAST(invoice_title AS VARCHAR(255))                    AS invoice_title,
    CAST(order_number AS VARCHAR(50))                      AS order_number,
    CAST(fk_order_id AS VARCHAR(64))                       AS fk_order_id,
    CAST(fk_order_number AS VARCHAR(50))                   AS fk_order_number,
    CAST(fk_recipient_id AS VARCHAR(64))                   AS fk_recipient_id,
    CAST(fk_subject_id AS VARCHAR(64))                     AS fk_subject_id,
    CAST(subject_archive_number AS VARCHAR(50))            AS subject_archive_number,
    CAST(subject_name AS VARCHAR(255))                     AS subject_name,
    CAST(fk_avdeling_id AS VARCHAR(64))                    AS fk_avdeling_id,
    CAST(fk_sted_id AS VARCHAR(64))                        AS fk_sted_id,
    TRY_CAST(created_at AS DATETIME2(6))                    AS created_at,
    CAST(created_by AS VARCHAR(100))                       AS created_by,
    TRY_CAST(modified_at AS DATETIME2(6))                   AS modified_at,
    CAST(modified_by AS VARCHAR(100))                      AS modified_by
FROM source
