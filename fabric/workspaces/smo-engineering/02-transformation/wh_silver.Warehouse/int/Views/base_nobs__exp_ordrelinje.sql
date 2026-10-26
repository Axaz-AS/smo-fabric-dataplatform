create view [int].[base_nobs__exp_ordrelinje] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_ordrelinje
),

renamed AS (
    SELECT
        [__kplt_ID]                                        AS pk_ordrelinje_id,
        [_kflt_Ordre_ID]                                   AS fk_ordre_id,
        [_kflt_Komponent_ID]                               AS fk_komponent_id,
        [_kflt__Person]                                    AS fk_person_id,
        [Status]                                           AS status,
        [Antall]                                           AS quantity_ordered,
        [AntallPlukket]                                    AS quantity_picked,
        [AntallLånt]                                       AS quantity_loaned,
        [AntallTilgjForReservasjon]                        AS quantity_available_for_reservation,
        [ArtikkelNummer_Intern]                            AS article_number_internal,
        [ArtikkelNummer_Lev]                               AS article_number_supplier,
        [ArtikkelBenevnelse_Intern]                        AS article_name_internal,
        [ArtikkelBenevnelse_Lev]                           AS article_name_supplier,
        [Avdeling]                                         AS department_name,
        [BatchNrLev]                                       AS batch_number_supplier,
        [Destinasjonskode]                                 AS destination_code,
        [Enhet]                                            AS unit,
        [Enhetspris]                                       AS unit_price,
        [Komponent_kategori]                               AS component_category,
        [LinjeBeloep]                                      AS line_amount,
        [Referanse]                                        AS reference,
        [Serienummer]                                      AS serial_number,
        TRY_CAST([BestiltDato] AS DATE)                    AS ordered_from_supplier_date,
        TRY_CAST([EgenbetalingFakturaDato] AS DATE)        AS copay_invoice_date,
        [EgenbetalingFakturanummer]                        AS copay_invoice_number,
        TRY_CAST([zz__IsDeleted] AS INT)                   AS is_deleted,
        TRY_CAST([zz__IsLocked] AS INT)                    AS is_locked,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2(6)) AS created_at,
        [zz__Creation_AccountName__lxt]                    AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2(6)) AS modified_at,
        [zz__Modification_AccountName__lxt]                AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2(6))   AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE is_deleted = 0 OR is_deleted IS NULL;

GO