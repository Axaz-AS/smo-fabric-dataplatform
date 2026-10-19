WITH enriched AS (
    SELECT * FROM {{ ref('int_gapvision__score_enriched') }}
)

SELECT
    TRY_CAST(company_id AS INT)                         AS company_id,
    TRY_CAST(response_id AS INT)                        AS response_id,
    CAST(measurement AS VARCHAR(255))                   AS measurement,
    CAST(event_name AS VARCHAR(255))                    AS event_name,
    CAST(measurement_group AS VARCHAR(255))             AS measurement_group,
    TRY_CAST(sorting AS INT)                            AS sorting,
    TRY_CAST(answer_date AS DATE)                       AS answer_date,
    CAST(question AS VARCHAR(500))                      AS question,
    CAST(answer_text AS VARCHAR(500))                   AS answer_text,
    TRY_CAST(score AS FLOAT)                            AS score,
    TRY_CAST(sendout_at AS DATETIME2(6))                AS sendout_at,
    TRY_CAST(answered_at AS DATETIME2(6))               AS answered_at,
    CAST(external_reference AS VARCHAR(255))            AS external_reference,
    CAST(respondent_comment AS VARCHAR(MAX))            AS respondent_comment
FROM enriched
