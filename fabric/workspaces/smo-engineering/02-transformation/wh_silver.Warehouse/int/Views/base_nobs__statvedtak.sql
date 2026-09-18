create view [int].[base_nobs__statvedtak] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.statvedtak
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_stat_vedtak_id,
        [_kflt_VedtakID]                                   AS fk_vedtak_id,
        [_kflt_OrdreID]                                    AS fk_ordre_id,
        [_kflt_PersonID]                                   AS fk_person_id,
        [_kflt_AvdelingID]                                 AS fk_avdeling_id,
        [Pasientnr]                                        AS patient_number,
        [Nomenklaturkode]                                  AS nomenclature_code,
        [Status]                                           AS status,
        [Type]                                             AS type,
        TRY_CAST([Dato_Vedtaksdato] AS DATE)               AS date_decision,
        TRY_CAST([Dato_SendtNAV] AS DATE)                  AS date_sent_nav,
        [_kalt_Type]                                       AS calc_type,
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
WHERE is_deleted = 0 OR is_deleted IS NULL;

GO