create view [int].[base_nobs__exp_diagnose] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_diagnose
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_diagnose_id,
        [_kflt_Person]                                     AS fk_person_id,
        [_kalt__Type]                                      AS fk_type_code,
        [Diagnose]                                         AS diagnosis,
        [Diagnose_Display]                                 AS diagnosis_display,
        [Klinisk_Hjelpemiddel_Type]                        AS clinical_aid_type,
        [Klinisk_Infolinje]                                AS clinical_info_line,
        [Klinisk_SkadeNivå]                                AS clinical_injury_level,
        [Klinisk_SkadeSide]                                AS clinical_injury_side,
        [Klinisk_SkadeType]                                AS clinical_injury_type,
        [Klinisk_Sår]                                      AS clinical_wound,
        [Klinisk_SårLokasjon]                              AS clinical_wound_location,
        TRY_CAST([Klinisk_SårLokasjonDato] AS DATE)        AS clinical_wound_location_date,
        [Klinisk_YrkesSkade]                               AS clinical_occupational_injury,
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