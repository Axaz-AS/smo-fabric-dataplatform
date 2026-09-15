/*
    Model: int_ops__patient_unified
    Domain: Operations (Ops)
    Grain: 1 row per patient (person_id)

    Business Logic & Assumptions:
    - Combines the full historical patient baseline from statpasient_detail (~42,000 rows)
      with the new master export tables exp_pasient and exp_personalia.
    - exp_pasient provides core identity and contact address (names, secret address flag,
      postal details, recall interval preferences).
    - exp_personalia provides clinical identity, national ID (fødselsnummer), exact birth date,
      gender, NAV customer number, geographic codes, and primary practitioner foreign keys.
    - statpasient_detail provides complete population coverage, patient number, approximate age,
      birth year, and initial department/municipality when new export records have not yet arrived.
    - Priority: exp_personalia and exp_pasient take precedence for overlapping fields;
      statpasient_detail serves as the fallback.
*/

WITH pasient_detail AS (
    SELECT * FROM {{ ref('base_nobs__pasient_detail') }}
),

pasient AS (
    SELECT * FROM {{ ref('base_nobs__pasient') }}
),

personalia AS (
    SELECT * FROM {{ ref('base_nobs__personalia') }}
),

all_patients AS (
    SELECT fk_person_id AS person_id FROM pasient_detail WHERE fk_person_id IS NOT NULL
    UNION
    SELECT pk_pasient_id AS person_id FROM pasient WHERE pk_pasient_id IS NOT NULL
    UNION
    SELECT fk_person_id AS person_id FROM personalia WHERE fk_person_id IS NOT NULL
),

unified AS (
    SELECT
        p.person_id                                        AS pk_patient_id,
        COALESCE(per.patient_number, pd.patient_number)    AS patient_number,
        pas.first_name,
        pas.last_name,
        CASE
            WHEN pas.first_name IS NOT NULL OR pas.last_name IS NOT NULL
            THEN TRIM(CONCAT(COALESCE(pas.first_name, ''), ' ', COALESCE(pas.last_name, '')))
            ELSE NULL
        END                                                AS full_name,
        per.national_id_number,
        per.birth_date,
        COALESCE(YEAR(per.birth_date), pd.birth_year)      AS birth_year,
        COALESCE(
            DATEDIFF(year, per.birth_date, GETDATE()),
            pd.age
        )                                                  AS approximate_age,
        per.gender,
        COALESCE(per.patient_status, pd.status)            AS patient_status,
        pd.status_code                                     AS patient_status_code,
        pas.patient_type,
        COALESCE(pas.is_address_secret, 'Nei')             AS is_address_secret,
        pas.address_line_1,
        pas.address_line_2,
        pas.postal_code,
        pas.city,
        pas.country,
        COALESCE(per.city_place, pd.municipality)          AS municipality,
        per.municipality_code,
        per.county,
        COALESCE(per.department, pd.department_name)       AS department_name,
        COALESCE(per.meeting_place, pd.meeting_place)      AS meeting_place,
        per.institution,
        per.nav_customer_number,

        -- Primary practitioner foreign keys with explicit roles
        per.fk_fastlege_id                                 AS fk_health_personnel_fastlege,
        per.fk_henvisende_lege_id                          AS fk_health_personnel_henvisende_lege,
        per.fk_rekvirent_id                                AS fk_health_personnel_rekvirent,
        per.fk_fysioterapeut_id                            AS fk_health_personnel_fysioterapeut,
        per.fk_ergoterapeut_id                             AS fk_health_personnel_ergoterapeut,
        per.fk_ortopediingenior_id                         AS fk_employee_ortopediingenior,

        -- Organization & location references
        pd.fk_avdeling_id                                  AS fk_avdeling_id,
        COALESCE(per.fk_sted_id, pd.fk_sted_id)            AS fk_sted_id,

        -- Recall scheduling attributes from exp_pasient
        pas.recall_interval,
        pas.recall_next,
        pas.recall_next_location,
        pas.recall_duration_hours,

        -- Data integration flags and audit timestamps
        CASE
            WHEN pas.pk_pasient_id IS NOT NULL OR per.pk_personalia_id IS NOT NULL THEN 1
            ELSE 0
        END                                                AS has_extended_profile,
        pd.date_created_business,
        COALESCE(pas.created_at, per.created_at, pd.created_at) AS created_at,
        COALESCE(pas.modified_at, per.modified_at, pd.modified_at) AS modified_at
    FROM all_patients p
    LEFT JOIN pasient_detail pd ON p.person_id = pd.fk_person_id
    LEFT JOIN pasient pas ON p.person_id = pas.pk_pasient_id
    LEFT JOIN personalia per ON p.person_id = per.fk_person_id
)

SELECT *
FROM unified
