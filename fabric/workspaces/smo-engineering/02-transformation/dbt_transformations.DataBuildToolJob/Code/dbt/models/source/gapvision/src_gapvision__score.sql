WITH source AS (
    SELECT * FROM {{ source('gapvision', 'V111_Score') }}
),

renamed AS (
    SELECT
        [FirmaID]                                AS company_id,
        [ResponseID]                             AS fk_response_id,
        [Måling]                                 AS measurement,
        [Hendelse]                               AS event_name,
        [Målepunkt]                              AS measurement_group,
        [Sortering]                              AS sorting,
        CAST([Svardato] AS DATE)                 AS answer_date,
        [Spørsmål]                               AS question,
        [Tekst]                                  AS answer_text,
        CAST([Score] AS FLOAT)                   AS score
    FROM source
)

SELECT * FROM renamed
