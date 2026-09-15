WITH source AS (
    SELECT * FROM {{ source('nobs', 'exp_hjelpemiddel') }}
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_hjelpemiddel_id,
        [_kflt__Person]                                    AS fk_person_id,
        [_kflt__VedtakID]                                  AS fk_vedtak_id,
        [_kalt_Fag]                                        AS fk_fag_code,
        [_kalt_Produksjonsmetode]                          AS fk_produksjonsmetode_code,
        [Navn]                                             AS name,
        [ICD10_Kode]                                       AS icd10_code,
        [ICD10_Forklaring]                                 AS icd10_description,
        [Nomenklatur_Hovedgruppe_Kode]                     AS nomenclature_main_group_code,
        [Nomenklatur_Hovedgruppe_Beskrivelse]              AS nomenclature_main_group_description,
        [Nomenklatur_Produkt_Kode]                         AS nomenclature_product_code,
        [Nomenklatur_Produkt_Beskrivelse]                  AS nomenclature_product_description,
        [Klinisk_AarsakTilBehov]                           AS clinical_cause_of_need,
        [Klinisk_SkadeNivå]                                AS clinical_injury_level,
        [Klinisk_SkadeType]                                AS clinical_injury_type,
        [Klinisk_Skadeside]                                AS clinical_injury_side,
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
WHERE (is_deleted = 0 OR is_deleted IS NULL)
