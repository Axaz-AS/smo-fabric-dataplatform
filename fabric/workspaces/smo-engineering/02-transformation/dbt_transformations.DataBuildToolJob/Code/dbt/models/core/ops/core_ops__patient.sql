/*
    Model: core_ops__patient
    Domain: Operations (Ops)
    Grain: 1 row per patient (pk_patient_id)

    Business Logic:
    - Master conformed patient dimension for Sophies Minde.
    - Unifies the full baseline population from statpasient_detail (~42,000 patients)
      with the new master export tables exp_pasient and exp_personalia.
    - Captures demographic attributes, address, administrative affiliations,
      and role-based references to primary external healthcare practitioners
      and internal orthopedic engineers.
*/

WITH unified AS (
    SELECT * FROM {{ ref('int_ops__patient_unified') }}
)

SELECT
    CAST(pk_patient_id AS VARCHAR(64))                     AS pk_patient_id,
    CAST(patient_number AS VARCHAR(50))                    AS patient_number,
    CAST(first_name AS VARCHAR(100))                       AS first_name,
    CAST(last_name AS VARCHAR(100))                        AS last_name,
    CAST(full_name AS VARCHAR(200))                        AS full_name,
    CAST(national_id_number AS VARCHAR(20))                AS national_id_number,
    TRY_CAST(birth_date AS DATE)                           AS birth_date,
    TRY_CAST(birth_year AS INT)                            AS birth_year,
    TRY_CAST(approximate_age AS INT)                       AS approximate_age,
    CAST(gender AS VARCHAR(20))                            AS gender,
    CAST(patient_status AS VARCHAR(50))                    AS patient_status,
    CAST(patient_status_code AS VARCHAR(50))               AS patient_status_code,
    CAST(patient_type AS VARCHAR(50))                      AS patient_type,
    CAST(is_address_secret AS BIT)                         AS is_address_secret,
    CAST(CASE WHEN is_address_secret = 1 THEN NULL ELSE address_line_1 END AS VARCHAR(255)) AS address_line_1,
    CAST(CASE WHEN is_address_secret = 1 THEN NULL ELSE address_line_2 END AS VARCHAR(255)) AS address_line_2,
    CAST(CASE WHEN is_address_secret = 1 THEN NULL ELSE postal_code END AS VARCHAR(20))     AS postal_code,
    CAST(CASE WHEN is_address_secret = 1 THEN NULL ELSE city END AS VARCHAR(100))           AS city,
    CAST(CASE WHEN is_address_secret = 1 THEN NULL ELSE country END AS VARCHAR(100))        AS country,
    CAST(CASE WHEN is_address_secret = 1 THEN NULL ELSE municipality END AS VARCHAR(100))   AS municipality,
    CAST(CASE WHEN is_address_secret = 1 THEN NULL ELSE municipality_code END AS VARCHAR(20)) AS municipality_code,
    CAST(CASE WHEN is_address_secret = 1 THEN NULL ELSE county END AS VARCHAR(100))         AS county,
    CAST(department_name AS VARCHAR(100))                  AS department_name,
    CAST(meeting_place AS VARCHAR(100))                    AS meeting_place,
    CAST(institution AS VARCHAR(255))                      AS institution,
    CAST(nav_customer_number AS VARCHAR(50))               AS nav_customer_number,

    -- Role-based foreign keys to external health personnel and employee dimensions
    CAST(fk_health_personnel_fastlege AS VARCHAR(64))      AS fk_health_personnel_fastlege,
    CAST(fk_health_personnel_henvisende_lege AS VARCHAR(64)) AS fk_health_personnel_henvisende_lege,
    CAST(fk_health_personnel_rekvirent AS VARCHAR(64))     AS fk_health_personnel_rekvirent,
    CAST(fk_health_personnel_fysioterapeut AS VARCHAR(64)) AS fk_health_personnel_fysioterapeut,
    CAST(fk_health_personnel_ergoterapeut AS VARCHAR(64))  AS fk_health_personnel_ergoterapeut,
    CAST(fk_employee_ortopediingenior AS VARCHAR(64))      AS fk_employee_ortopediingenior,

    -- Organizational keys
    CAST(fk_avdeling_id AS VARCHAR(64))                    AS fk_avdeling_id,
    CAST(fk_sted_id AS VARCHAR(64))                        AS fk_sted_id,

    -- Recall scheduling details
    CAST(recall_interval AS VARCHAR(50))                   AS recall_interval,
    CAST(recall_next AS VARCHAR(100))                      AS recall_next,
    CAST(recall_next_location AS VARCHAR(255))             AS recall_next_location,
    TRY_CAST(recall_duration_hours AS FLOAT)               AS recall_duration_hours,
    CAST(recall_opbh_interval AS VARCHAR(50))              AS recall_opbh_interval,
    CAST(recall_opbh_next AS VARCHAR(100))                 AS recall_opbh_next,
    CAST(recall_time_preference AS VARCHAR(100))           AS recall_time_preference,
    TRY_CAST(recall_last_followup_date AS DATE)            AS recall_last_followup_date,
    CAST(bank_account_number AS VARCHAR(50))               AS bank_account_number,
    CAST(reminders AS VARCHAR(4000))                       AS reminders,

    -- Metadata & audit
    CAST(has_extended_profile AS BIT)                      AS has_extended_profile,
    TRY_CAST(date_created_business AS DATE)                AS date_created_business,
    TRY_CAST(created_at AS DATETIME2(6))                   AS created_at,
    TRY_CAST(modified_at AS DATETIME2(6))                  AS modified_at
FROM unified
