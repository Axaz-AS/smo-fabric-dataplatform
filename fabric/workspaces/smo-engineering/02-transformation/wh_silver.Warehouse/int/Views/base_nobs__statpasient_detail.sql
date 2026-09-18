create view [int].[base_nobs__statpasient_detail] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.statpasient_detail
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_pasient_detail_id,
        [_kflt_PersonID]                                   AS fk_person_id,
        [_kflt_AvdelingID]                                 AS fk_avdeling_id,
        [_kflt_StedID]                                     AS fk_sted_id,
        [Pasientnr]                                        AS patient_number,
        [Alder]                                            AS age,
        [Foedselsaar]                                      AS birth_year,
        [Status]                                           AS status,
        [Status_kode]                                      AS status_code,
        TRY_CAST([Dato_opprettet] AS DATE)                 AS date_created_business,
        [Avdeling]                                         AS department_name,
        [Kommune]                                          AS municipality,
        [Moetested]                                        AS meeting_place,
        TRY_CAST([zz__IsDeleted] AS INT)                   AS is_deleted,
        TRY_CAST([zz__IsLocked] AS INT)                    AS is_locked,
        [zz__dummy]                                        AS dummy,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2(6)) AS created_at,
        [zz__Creation_AccountName__lxt]                    AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2(6)) AS modified_at,
        [zz__Modification_AccountName__lxt]                AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2(6))      AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE (is_deleted = 0 OR is_deleted IS NULL)
    AND dummy IS NULL;

GO