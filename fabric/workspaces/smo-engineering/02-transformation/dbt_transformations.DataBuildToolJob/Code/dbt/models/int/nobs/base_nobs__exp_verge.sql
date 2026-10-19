WITH source AS (
    SELECT * FROM {{ source('nobs', 'exp_verge') }}
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_verge_id,
        [_kflt__Person_ForesattFor]                        AS fk_person_id,
        [Fornavn]                                          AS first_name,
        [Etternavn]                                        AS last_name,
        CASE
            WHEN CHARINDEX(CHAR(13), [Telefonnummer]) > 0
            THEN TRIM(SUBSTRING([Telefonnummer], 1, CHARINDEX(CHAR(13), [Telefonnummer]) - 1))
            WHEN CHARINDEX(CHAR(10), [Telefonnummer]) > 0
            THEN TRIM(SUBSTRING([Telefonnummer], 1, CHARINDEX(CHAR(10), [Telefonnummer]) - 1))
            ELSE NULLIF(TRIM([Telefonnummer]), '')
        END                                                AS phone_number,
        CASE
            WHEN CHARINDEX(CHAR(13), [Epost]) > 0
            THEN TRIM(SUBSTRING([Epost], 1, CHARINDEX(CHAR(13), [Epost]) - 1))
            WHEN CHARINDEX(CHAR(10), [Epost]) > 0
            THEN TRIM(SUBSTRING([Epost], 1, CHARINDEX(CHAR(10), [Epost]) - 1))
            ELSE NULLIF(TRIM([Epost]), '')
        END                                                AS email,
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
