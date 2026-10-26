WITH source AS (
    SELECT * FROM {{ source('nobs', 'exp_faktura') }}
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_invoice_id,
        [Fakturanummer]                                    AS invoice_number,
        TRY_CAST([Fakturadato] AS DATE)                     AS invoice_date,
        TRY_CAST([BetalingsDato] AS DATE)                   AS payment_due_date,
        TRY_CAST([DatoInnbetalt] AS DATE)                   AS paid_date,
        [_kalt__FakturaType]                                AS invoice_type,
        [_kalt__Type]                                       AS invoice_kind,
        [_kalt__Status]                                     AS invoice_status,
        [_kalt__KundeKategori]                              AS customer_category,
        [_kalt_BetalingsMåte]                               AS payment_method,
        [_kalt__UtbetalesVia]                               AS paid_via,
        [_kalt_FakturamottakerPrivat]                       AS billing_recipient_private,
        [FaktureringKundeNavn]                              AS billing_customer_name,
        [RegningsMottakerID]                                AS billing_recipient_id,
        [Avdelingkode]                                      AS department_code,
        [Avdelingkode_Hoved]                                AS main_department_code,
        TRY_CAST([FakturaTotalFørMVA__lcn] AS FLOAT)        AS total_before_vat,
        TRY_CAST([FakturaTotal__lcn] AS FLOAT)              AS total_incl_vat,
        TRY_CAST([MVA_normal__lcn] AS FLOAT)                AS vat_amount,
        TRY_CAST([Faktura_IkkeInnbetalt_lcn] AS FLOAT)      AS outstanding_amount,
        TRY_CAST([InnbetaltBeløp] AS FLOAT)                 AS paid_amount,
        TRY_CAST([Kredit_TilUtbetaling] AS FLOAT)           AS credit_amount,
        TRY_CAST([EB_Egenbetaling_Beløp] AS FLOAT)          AS copay_amount,
        [EB_Egenbetaling]                                   AS copay_indicator,
        TRY_CAST([DirekteDialog_Beløp] AS FLOAT)            AS direct_dialog_amount,
        TRY_CAST([DirekteDialog_Betalingsdato] AS DATE)     AS direct_dialog_payment_date,
        [DirekteDialog_Kontering]                           AS direct_dialog_accounting,
        [Kontonummer_kreditering]                           AS credit_account_number,
        [Kreditert_referanse]                               AS credit_reference,
        [RekvisisjonsNummer]                                AS requisition_number,
        [TilleggsReferanse]                                 AS additional_reference,
        [FakturaNote]                                       AS invoice_note,
        [FakturaTittel__NOBS]                               AS invoice_title,
        [Ordrenr__lxt]                                      AS order_number,
        [_kflt_OrdreID]                                     AS fk_order_id,
        [_kflt_OrdreNr]                                     AS fk_order_number,
        [_kflt_MottakerID]                                  AS fk_recipient_id,
        [_kflt_OmhandlerID]                                 AS fk_subject_id,
        [Omhandler_arkivnr__NOBS__lxt]                      AS subject_archive_number,
        [Omhandler_navn__NOBS__lxt]                         AS subject_name,
        [_kflt_AvdelingID]                                  AS fk_avdeling_id,
        [_kflt_StedID]                                      AS fk_sted_id,
        TRY_CAST([zz__IsDeleted] AS INT)                    AS is_deleted,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2(6)) AS created_at,
        [zz__Creation_AccountName__lxt]                     AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2(6)) AS modified_at,
        [zz__Modification_AccountName__lxt]                 AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2(6))      AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE (is_deleted = 0 OR is_deleted IS NULL)
