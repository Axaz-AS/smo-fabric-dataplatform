create view [int].[base_nobs__exp_kontakt] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_kontakt
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_kontakt_id,
        [_kflt__Person]                                    AS fk_person_id,
        [Type_as_text]                                     AS contact_type,
        [Nummer]                                           AS contact_value,
        TRY_CAST([SMS] AS INT)                             AS is_sms,
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