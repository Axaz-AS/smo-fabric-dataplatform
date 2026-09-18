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
    u.source_origin,
    u.source_record_id,
    u.appointment_record_type,
    u.fk_patient,
    u.patient_archive_number,
    u.appointment_date,
    u.start_time,
    u.end_time,
    u.duration,
    u.appointment_type,
    u.appointment_title,
    u.fk_employee_responsible,
    u.responsible_employee_name,
    u.fk_employee_performing,
    u.employee_count,
    u.employee_initials,
    u.location_name,
    u.fk_sted_id,
    u.fk_avdeling_id,
    u.department_name,
    u.arrived_at,
    u.checked_out_at,
    u.did_not_arrive_at,
    u.attendance_status,
    u.created_at,
    u.created_by,
    u.modified_at,
    u.modified_by
FROM unified u
INNER JOIN patients p
    ON u.fk_patient = p.pk_patient_id
