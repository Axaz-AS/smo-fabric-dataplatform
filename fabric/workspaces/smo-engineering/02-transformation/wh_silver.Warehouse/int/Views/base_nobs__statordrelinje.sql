create view [int].[base_nobs__statordrelinje] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.statordrelinje
),

renamed AS (
    SELECT
        [__kplt_ID]                                        AS pk_ordrelinje_id,
        [_kflt_Ordre_ID]                                   AS fk_ordre_id,
        [_kflt_Ordrelinje_ID]                              AS fk_parent_ordrelinje_id,
        [_kflt_Komponent_ID]                               AS fk_komponent_id,
        [_kflt_Leverandoer_ID]                             AS fk_leverandoer_id,
        [_kflt_AvdelingID]                                 AS fk_avdeling_id,
        [_kflt_Sted_ID]                                    AS fk_sted_id,
        [Ordenummer]                                       AS order_number,
        [Status]                                           AS status,
        [Produksjonsstatus]                                AS production_status,
        [NomenklaturKode]                                  AS nomenclature_code,
        [Destinasjonskode]                                 AS destination_code,
        [Antall]                                           AS quantity_ordered,
        [AntallPlukket]                                    AS quantity_picked,
        [ArtikkelNummer_Intern]                            AS article_number_internal,
        [ArtikkelNummer_Lev]                               AS article_number_supplier,
        [ArtikkelBenevnelse_Intern]                        AS article_name_internal,
        [ArtikkelBenevnelse_Lev]                           AS article_name_supplier,
        [LeverandoerNr]                                    AS supplier_number,
        [LeverandoerAdmNr]                                 AS supplier_admin_number,
        [Leverandoernavn]                                  AS supplier_name,
        [Enhetspris]                                       AS unit_price,
        [Enhetspris_inn]                                   AS unit_price_in,
        [Enhetspris_ut]                                    AS unit_price_out,
        [LinjeBeloep]                                      AS line_amount,
        [LinjeBeloepPlukket_inn]                           AS line_amount_picked_in,
        [LinjeBeloepPlukket_ut]                            AS line_amount_picked_out,
        [Fakturanummer]                                    AS invoice_number,
        [EgenbetalingFakturanummer]                        AS copay_invoice_number,
        TRY_CAST([Ordredato] AS DATE)                      AS order_date,
        TRY_CAST([RegistrertDato] AS DATE)                 AS registered_date,
        TRY_CAST([BestiltDato] AS DATE)                    AS ordered_from_supplier_date,
        TRY_CAST([PlukketDato] AS DATE)                    AS picked_date,
        TRY_CAST([FakturaDato] AS DATE)                    AS invoice_date,
        TRY_CAST([EgenbetalingFakturaDato] AS DATE)        AS copay_invoice_date,
        [Avdeling]                                         AS department_name,
        [StedNavn]                                         AS location_name,
        TRY_CAST([zz__IsDeleted] AS INT)                   AS is_deleted,
        TRY_CAST([zz__IsLocked] AS INT)                    AS is_locked,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2(6)) AS created_at,
        [zz__Creation_AccountName__lxt]                    AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2(6)) AS modified_at,
        [zz__Modification_AccountName__lxt]                AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2(6))      AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE is_deleted = 0 OR is_deleted IS NULL;

GO