WITH core_scores AS (
    SELECT * FROM {{ ref('core_gapvision_score') }}
),

monthly_agg AS (
    SELECT
        company_id,
        measurement,
        measurement_group,
        question,
        DATEFROMPARTS(YEAR(answer_date), MONTH(answer_date), 1) AS score_month,
        COUNT(response_id)                                      AS total_responses,
        AVG(score)                                              AS average_score,
        MIN(score)                                              AS min_score,
        MAX(score)                                              AS max_score
    FROM core_scores
    WHERE answer_date IS NOT NULL
    GROUP BY
        company_id,
        measurement,
        measurement_group,
        question,
        DATEFROMPARTS(YEAR(answer_date), MONTH(answer_date), 1)
)

SELECT * FROM monthly_agg
