WITH source AS (
    SELECT * FROM {{ source('gapvision', 'V111_Utsendelse') }}
),

renamed AS (
    SELECT
        [FirmaID]                                AS company_id,
        [ResponseID]                             AS pk_response_id,
        [Måling]                                 AS measurement,
        [Hendelse]                               AS event_name,
        [Målepunkt]                              AS measurement_group,
        CAST([Utsendtdato] AS DATETIME2(6))         AS sendout_at,
        CAST([Svardato] AS DATETIME2(6))            AS answered_at,
        [ExternalReference]                      AS external_reference,
        [Respondentkommentar]                    AS respondent_comment
    FROM source
)

SELECT * FROM renamed
