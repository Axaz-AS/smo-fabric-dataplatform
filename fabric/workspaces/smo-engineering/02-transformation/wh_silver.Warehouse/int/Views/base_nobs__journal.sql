create view [int].[base_nobs__journal] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_journal
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_journal_id,
        [_kflt__Person]                                    AS fk_person_id,
        [_kflt__Ordre]                                     AS fk_ordre_id,
        TRY_CAST([Dato] AS DATE)                           AS journal_date,
        [EPJDokumentType]                                  AS epj_document_type,
        [Sak_Type]                                         AS case_type,
        [Journaltekst]                                     AS journal_text,
        [Opprettet_Av]                                     AS created_by_user,
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