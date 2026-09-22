/*
    Model: fct_ops_lop_appointment
    Domain: Operations (Ops) — Consumer: LOP (Sophies Minde migration import)
    Grain: 1 row per appointment record per source system (pk_appointment_id)

    Business Logic:
    - Appointment fact for the LOP migration import data product. LOP fetches
      historical appointments as JSON from the datalake; this table is the
      source of that export.
    - Field selection follows the NOBS-to-LOP mapping workbook: appointment
      type, date, start, end, responsible employee, location and attendance.
    - Historical migration scope: 'occurred' records (statevent visit events,
      ~114.7k rows) cover the patient visits that LOP wants as history.
      'booked' records (exp_avtaler) are included for completeness — LOP
      handles future bookings natively, so the JSON export should filter on
      appointment_record_type / appointment_date as agreed with Tieto.
    - Responsible employee: the statevent source carries employee initials
      rather than an employee FK; fk_employee_responsible is NULL for all
      occurred records today. employee_initials and responsible_employee_name
      (booked records) are therefore kept for identity resolution in LOP.
    - Draft scope: exp_avtaler currently contains an 11-row sample; statevent
      carries the full historical visit population. Revisit when the full
      NOBS export arrives.
*/

WITH appointments AS (
    SELECT * FROM {{ ref('core_ops__appointment') }}
)

SELECT
    pk_appointment_id,
    source_origin,
    source_record_id,
    appointment_record_type,
    fk_patient,

    -- Scheduling (LOP: appointment date / start / end)
    appointment_date,
    start_time,
    end_time,
    duration,
    appointment_type,
    appointment_title,

    -- Responsible employee (LOP: responsible employee per appointment)
    fk_employee_responsible,
    responsible_employee_name,
    fk_employee_performing,
    employee_initials,

    -- Location (LOP: appointment/location)
    location_name,
    department_name,

    -- Attendance (LOP: whether the patient attended)
    attendance_status,
    arrived_at,
    checked_out_at,
    did_not_arrive_at,

    -- Audit
    created_at,
    modified_at
FROM appointments
