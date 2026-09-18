create view [int].[base_nobs__statnomenklatur_detail] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.statnomenklatur_detail
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_nomenklatur_detail_id,
        [_kflt_AvdelingID]                                 AS fk_avdeling_id,
        [_kflt_StedID]                                     AS fk_sted_id,
        [NomenklaturKode]                                  AS nomenclature_code,
        [Nomenklatur_Produkt_Kode]                         AS product_code,
        [Nomenklatur_Produkt_Navn__lct]                    AS product_name,
        [Nomenklatur_Produkt_Tekst]                        AS product_description,
        [Ordretype]                                        AS order_type,
        [_kalt_Status]                                     AS calc_status,
        [_kalt_Type]                                       AS calc_type,
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