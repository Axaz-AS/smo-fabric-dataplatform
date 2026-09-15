create view [int].[base_nobs__avtaler] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_avtaler
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_avtale_id,
        [_kflt__Person]                                    AS fk_person_id,
        TRY_CAST([Dato] AS DATE)                           AS date_business,
        [Medarbeider]                                      AS employee_name,
        [Start]                                            AS start_time,
        [Slutt]                                            AS end_time,
        [Sted]                                             AS location,
        [Tittel]                                           AS title,
        [Type]                                             AS appointment_type,
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