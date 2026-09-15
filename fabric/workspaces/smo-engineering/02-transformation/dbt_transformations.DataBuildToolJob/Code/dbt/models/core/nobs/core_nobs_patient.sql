/*
    Model: core_nobs_patient
    Domain: NOBS
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
    SELECT * FROM {{ ref('int_nobs__patient_unified') }}
)

SELECT
    pk_patient_id,
    patient_number,
    first_name,
    last_name,
    full_name,
    national_id_number,
    birth_date,
    birth_year,
    approximate_age,
    gender,
    patient_status,
    patient_status_code,
    patient_type,
    is_address_secret,
    address_line_1,
    address_line_2,
    postal_code,
    city,
    country,
    municipality,
    municipality_code,
    county,
    department_name,
    meeting_place,
    institution,
    nav_customer_number,

    -- Role-based foreign keys to external health personnel and employee dimensions
    fk_health_personnel_fastlege,
    fk_health_personnel_henvisende_lege,
    fk_health_personnel_rekvirent,
    fk_health_personnel_fysioterapeut,
    fk_health_personnel_ergoterapeut,
    fk_employee_ortopediingenior,

    -- Organizational keys
    fk_avdeling_id,
    fk_sted_id,

    -- Recall scheduling details
    recall_interval,
    recall_next,
    recall_next_location,
    recall_duration_hours,

    -- Metadata & audit
    has_extended_profile,
    date_created_business,
    created_at,
    modified_at
FROM unified
