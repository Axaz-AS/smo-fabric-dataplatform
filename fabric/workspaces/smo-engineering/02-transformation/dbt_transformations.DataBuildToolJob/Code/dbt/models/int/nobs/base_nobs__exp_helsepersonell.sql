WITH source AS (
    SELECT * FROM {{ source('nobs', 'exp_helsepersonell') }}
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_helsepersonell_id,
        [ID_nummer]                                        AS employee_id_number,
        [Fornavn]                                          AS first_name,
        [Etternavn]                                        AS last_name,
        [Kategori]                                         AS category,
        [Profesjon]                                        AS profession,
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
