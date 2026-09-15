create view [int].[base_nobs__medarbeider] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_medarbeider
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_medarbeider_id,
        [Brukernavn]                                       AS username,
        [Fornavn]                                          AS first_name,
        [Etternavn]                                        AS last_name,
        [Fulltnavn]                                        AS full_name,
        [Forkortelse]                                      AS abbreviation,
        [Tittel]                                           AS title,
        [Type_Ressurs]                                     AS resource_type,
        [Avdeling]                                         AS department,
        [Lagersted]                                        AS storage_location,
        [Epost]                                            AS email,
        [Adresse_AdresseLinje1]                            AS address_line_1,
        [Adresse_AdresseLinje2]                            AS address_line_2,
        [Adresse_Postnr]                                   AS postal_code,
        [Adresse_Poststed]                                 AS city,
        [Adresse_Land]                                     AS country,
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