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
    SELECT * FROM {{ ref('base_nobs__statpasient_detail') }}
),

pasient AS (
    SELECT * FROM {{ ref('base_nobs__exp_pasient') }}
),

personalia AS (
    SELECT * FROM {{ ref('base_nobs__exp_personalia') }}
),

helsepersonell AS (
    SELECT * FROM {{ ref('base_nobs__exp_helsepersonell') }}
),

-- Primary contact points per person: rank the latest contact within each
-- normalized category (mobile, phone, email) and pivot to one row per person.
contact_ranked AS (
    SELECT
        fk_person_id,
        contact_value,
        CASE
            WHEN LOWER(contact_type) LIKE '%mobil%' THEN 'mobile_number'
            WHEN LOWER(contact_type) LIKE '%telefon%' OR LOWER(contact_type) LIKE '%tlf%' THEN 'phone_number'
            WHEN LOWER(contact_type) LIKE '%epost%' OR LOWER(contact_type) LIKE '%e-post%' OR contact_value LIKE '%@%' THEN 'email_address'
        END AS contact_category,
        ROW_NUMBER() OVER (
            PARTITION BY
                fk_person_id,
                CASE
                    WHEN LOWER(contact_type) LIKE '%mobil%' THEN 'mobile_number'
                    WHEN LOWER(contact_type) LIKE '%telefon%' OR LOWER(contact_type) LIKE '%tlf%' THEN 'phone_number'
                    WHEN LOWER(contact_type) LIKE '%epost%' OR LOWER(contact_type) LIKE '%e-post%' OR contact_value LIKE '%@%' THEN 'email_address'
                END
            ORDER BY COALESCE(modified_at, created_at) DESC, pk_kontakt_id DESC
        ) AS rn
    FROM {{ ref('base_nobs__exp_kontakt') }}
    WHERE contact_value IS NOT NULL AND TRIM(contact_value) != ''
),

contact_primary AS (
    SELECT
        fk_person_id,
        MAX(CASE WHEN contact_category = 'mobile_number' THEN contact_value END) AS mobile_number,
        MAX(CASE WHEN contact_category = 'phone_number' THEN contact_value END)  AS phone_number,
        MAX(CASE WHEN contact_category = 'email_address' THEN contact_value END) AS email_address
    FROM contact_ranked
    WHERE rn = 1 AND contact_category IS NOT NULL
    GROUP BY fk_person_id
),

-- Full-export validation: exp_pasient carries blank ghost stubs (no name, and
-- with no patient number / personalia match downstream) that would violate the
-- core_ops__patient.patient_number not_null contract. Exclude nameless stubs.
all_patients AS (
    SELECT fk_person_id AS person_id FROM pasient_detail WHERE fk_person_id IS NOT NULL
    UNION
    SELECT pk_pasient_id AS person_id FROM pasient WHERE pk_pasient_id IS NOT NULL AND (first_name IS NOT NULL OR last_name IS NOT NULL)
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
        COALESCE(pas.is_address_secret, CAST(0 AS BIT))             AS is_address_secret,
        CASE WHEN pas.is_address_secret = 1 THEN NULL ELSE pas.address_line_1 END AS address_line_1,
        CASE WHEN pas.is_address_secret = 1 THEN NULL ELSE pas.address_line_2 END AS address_line_2,
        CASE WHEN pas.is_address_secret = 1 THEN NULL ELSE pas.postal_code END AS postal_code,
        CASE WHEN pas.is_address_secret = 1 THEN NULL ELSE pas.city END AS city,
        CASE WHEN pas.is_address_secret = 1 THEN NULL ELSE pas.country END AS country,
        CASE WHEN pas.is_address_secret = 1 THEN NULL ELSE COALESCE(per.city_place, pd.municipality) END AS municipality,
        CASE WHEN pas.is_address_secret = 1 THEN NULL ELSE per.municipality_code END AS municipality_code,
        CASE WHEN pas.is_address_secret = 1 THEN NULL ELSE per.county END AS county,

        -- Primary contact points (latest per category from exp_kontakt)
        con.mobile_number,
        con.phone_number,
        con.email_address,

        COALESCE(per.department, pd.department_name)       AS department_name,
        COALESCE(per.meeting_place, pd.meeting_place)      AS meeting_place,
        per.institution,
        per.nav_customer_number,

        -- Primary practitioner foreign keys with explicit roles
        per.fk_fastlege_id                                 AS fk_health_personnel_fastlege,
        per.fk_henvisende_lege_id                          AS fk_health_personnel_henvisende_lege,
        per.fk_rekvirent_id                                AS fk_health_personnel_rekvirent,
        hp_rekvirent.employee_id_number                    AS rekvirent_hpr_number,
        CASE
            WHEN hp_rekvirent.first_name IS NOT NULL OR hp_rekvirent.last_name IS NOT NULL
            THEN TRIM(CONCAT(COALESCE(hp_rekvirent.first_name, ''), ' ', COALESCE(hp_rekvirent.last_name, '')))
            ELSE NULL
        END                                                AS rekvirent_name,
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
        pas.recall_opbh_interval,
        pas.recall_opbh_next,
        pas.recall_time_preference,
        pas.recall_last_followup_date,
        pas.bank_account_number,
        pas.reminders,

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
    LEFT JOIN helsepersonell hp_rekvirent ON per.fk_rekvirent_id = hp_rekvirent.pk_helsepersonell_id
    LEFT JOIN contact_primary con ON p.person_id = con.fk_person_id
)

SELECT *
FROM unified
WHERE patient_number IS NOT NULL
