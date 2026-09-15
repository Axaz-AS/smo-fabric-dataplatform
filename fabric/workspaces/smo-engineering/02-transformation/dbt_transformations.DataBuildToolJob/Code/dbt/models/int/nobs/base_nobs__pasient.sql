WITH source AS (
    SELECT * FROM {{ source('nobs', 'exp_pasient') }}
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_pasient_id,
        [Fornavn]                                          AS first_name,
        [Etternavn]                                        AS last_name,
        [Type]                                             AS patient_type,
        [Adresse_AdresseLinje1]                            AS address_line_1,
        [Adresse_AdresseLinje2]                            AS address_line_2,
        [Adresse_Postnr]                                   AS postal_code,
        [Adresse_Poststed]                                 AS city,
        [Adresse_Land]                                     AS country,
        [Adresse_Hemmelig]                                 AS is_address_secret,
        [Innkalling_Intervall]                             AS recall_interval,
        [Innkalling_Neste]                                 AS recall_next,
        [Innkalling_Neste_Sted]                            AS recall_next_location,
        [Innkalling_OPBH_Intervall]                        AS recall_opbh_interval,
        [Innkalling_OPBH_Neste]                            AS recall_opbh_next,
        TRY_CAST([Innkalling_AvtaleVarighet] AS FLOAT)     AS recall_duration_hours,
        [Innkalling_KlokkeslettØnske]                      AS recall_time_preference,
        TRY_CAST([Innkalling_Siste_OppfølgingOppgaveDato] AS DATE) AS recall_last_followup_date,
        [KontonummerBank]                                  AS bank_account_number,
        [Påminnelser]                                      AS reminders,
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
