create view [int].[base_nobs__exp_gipslager] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_gipslager
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_gipslager_id,
        [_kflt__Person]                                    AS fk_person_id,
        TRY_CAST([Dato_Kastes] AS DATE)                    AS date_discard,
        TRY_CAST([Dato_Til_Lager] AS DATE)                 AS date_to_storage,
        [Kategori]                                         AS category,
        [Ordrenummer]                                      AS order_number,
        [Sted]                                             AS location,
        TRY_CAST([zz__IsDeleted] AS INT)                   AS is_deleted,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2(6)) AS created_at,
        [zz__Creation_AccountName__lxt]                    AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2(6)) AS modified_at,
        [zz__Modification_AccountName__lxt]                AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2(6))      AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE (is_deleted = 0 OR is_deleted IS NULL);

GO