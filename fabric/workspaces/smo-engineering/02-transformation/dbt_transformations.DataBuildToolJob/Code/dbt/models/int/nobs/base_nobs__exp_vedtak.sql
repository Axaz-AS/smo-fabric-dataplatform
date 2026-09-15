WITH source AS (
    SELECT * FROM {{ source('nobs', 'exp_vedtak') }}
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_exp_vedtak_id,
        [_kflt__Person]                                    AS fk_person_id,
        [_kflt__Ordre]                                     AS fk_ordre_id,
        [_kflt_VedtakType]                                 AS fk_vedtak_type_code,
        [OPPR_NavnVedtak]                                  AS decision_name,
        [OPPR_ICD10Kode]                                   AS decision_icd10_code,
        TRY_CAST([OPPR_VedtakForlengelse_Dato_Utgår] AS DATE) AS decision_extension_expiration_date,
        TRY_CAST([FORN_Fornyelse_Dato_Utgår] AS DATE)      AS renewal_expiration_date,
        [FORN_NavnVedtak_og_StatusTekst]                   AS renewal_status_text,
        [FORN__kalt_FornyelseStatus]                       AS renewal_status_code,
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
