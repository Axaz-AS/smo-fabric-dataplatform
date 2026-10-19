/*
    Model: core_ops__appointment
    Domain: Operations (Ops)
    Grain: 1 row per appointment record per source system (pk_appointment_id)

    Business Logic:
    - Conformed appointment entity unifying exp_avtaler bookings ('booked') with
      statevent occurred patient visits ('occurred') via int_ops__appointment_unified.
    - Booked/occurred duality: the two sources carry no link key between a booking
      and its corresponding visit event, so one real-world visit may legitimately
      appear as a booking record, an event record, or both. source_origin and
      source_record_id disambiguate and compose the surrogate key pk_appointment_id.
    - Inner join to core_ops__patient scopes appointments to the conformed
      patient population.
*/

WITH unified AS (
    SELECT * FROM {{ ref('int_ops__appointment_unified') }}
),

patients AS (
    SELECT pk_patient_id FROM {{ ref('core_ops__patient') }}
)

SELECT
    CAST(CONCAT(u.source_origin, '|', u.source_record_id) AS VARCHAR(200)) AS pk_appointment_id,
    CAST(u.source_origin AS VARCHAR(20))                  AS source_origin,
    CAST(u.source_record_id AS VARCHAR(64))               AS source_record_id,
    CAST(u.appointment_record_type AS VARCHAR(20))        AS appointment_record_type,
    CAST(u.fk_patient AS VARCHAR(64))                     AS fk_patient,
    CAST(u.patient_archive_number AS VARCHAR(50))         AS patient_archive_number,
    TRY_CAST(u.appointment_date AS DATE)                  AS appointment_date,
    CAST(u.start_time AS VARCHAR(50))                     AS start_time,
    CAST(u.end_time AS VARCHAR(50))                       AS end_time,
    CAST(u.duration AS VARCHAR(50))                       AS duration,
    TRY_CAST(u.duration_minutes AS INT)                   AS duration_minutes,
    CAST(u.appointment_type AS VARCHAR(100))              AS appointment_type,
    CAST(u.appointment_title AS VARCHAR(255))             AS appointment_title,
    CAST(u.fk_employee_responsible AS VARCHAR(64))        AS fk_employee_responsible,
    CAST(u.responsible_employee_name AS VARCHAR(255))     AS responsible_employee_name,
    CAST(u.fk_employee_performing AS VARCHAR(64))         AS fk_employee_performing,
    TRY_CAST(u.employee_count AS INT)                     AS employee_count,
    CAST(u.employee_initials AS VARCHAR(255))             AS employee_initials,
    CAST(u.location_name AS VARCHAR(255))                 AS location_name,
    CAST(u.fk_sted_id AS VARCHAR(64))                     AS fk_sted_id,
    CAST(u.fk_avdeling_id AS VARCHAR(64))                 AS fk_avdeling_id,
    CAST(u.department_name AS VARCHAR(255))               AS department_name,
    TRY_CAST(u.arrived_at AS DATETIME2(6))                AS arrived_at,
    TRY_CAST(u.checked_out_at AS DATETIME2(6))            AS checked_out_at,
    TRY_CAST(u.did_not_arrive_at AS DATETIME2(6))         AS did_not_arrive_at,
    CAST(u.attendance_status AS VARCHAR(50))              AS attendance_status,
    TRY_CAST(u.created_at AS DATETIME2(6))                AS created_at,
    CAST(u.created_by AS VARCHAR(100))                    AS created_by,
    TRY_CAST(u.modified_at AS DATETIME2(6))               AS modified_at,
    CAST(u.modified_by AS VARCHAR(100))                   AS modified_by
FROM unified u
INNER JOIN patients p
    ON u.fk_patient = p.pk_patient_id
