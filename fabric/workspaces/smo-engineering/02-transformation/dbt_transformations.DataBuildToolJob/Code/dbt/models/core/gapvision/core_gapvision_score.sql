WITH enriched AS (
    SELECT * FROM {{ ref('int_gapvision__score_enriched') }}
)

SELECT
    company_id,
    response_id,
    measurement,
    event_name,
    measurement_group,
    sorting,
    answer_date,
    question,
    answer_text,
    score,
    sendout_at,
    answered_at,
    external_reference,
    respondent_comment
FROM enriched
