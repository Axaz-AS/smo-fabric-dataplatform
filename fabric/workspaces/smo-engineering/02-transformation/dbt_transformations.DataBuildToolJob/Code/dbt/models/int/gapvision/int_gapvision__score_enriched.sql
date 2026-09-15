WITH scores AS (
    SELECT * FROM {{ ref('src_gapvision__score') }}
),

utsendelse AS (
    SELECT * FROM {{ ref('src_gapvision__utsendelse') }}
),

joined AS (
    SELECT
        s.company_id,
        s.fk_response_id                         AS response_id,
        s.measurement,
        s.event_name,
        s.measurement_group,
        s.sorting,
        s.answer_date,
        s.question,
        s.answer_text,
        s.score,
        u.sendout_at,
        u.answered_at,
        u.external_reference,
        u.respondent_comment
    FROM scores s
    LEFT JOIN utsendelse u
        ON s.company_id = u.company_id
        AND s.fk_response_id = u.pk_response_id
)

SELECT * FROM joined
