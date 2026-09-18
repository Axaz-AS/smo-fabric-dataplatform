/*
    Model: int_ops__appointment_unified
    Domain: Operations (Ops)
    Grain: 1 row per appointment record from exp_avtaler (booked) or statevent (occurred)

    Business Logic & Assumptions:
    - Unifies booked appointments from exp_avtaler with occurred patient-visit
      events from statevent into one structurally aligned UNION ALL.
    - The two sources share no link key, so the same real-world visit may exist
      as a booking, an event, or both; appointment_record_type marks booked vs occurred.
    - Deferred base-view casts: base_nobs__exp_avtaler / base_nobs__statevent expose
      start_time, end_time, duration and the employee foreign keys as untyped
      Delta pass-throughs, and the two tables' time columns may differ in type.
      Explicit casts here align both branches positionally and by type until the
      casts move into the base views.
*/

WITH avtaler AS (
    SELECT * FROM {{ ref('base_nobs__exp_avtaler') }}
),

event AS (
    SELECT * FROM {{ ref('base_nobs__statevent') }}
),

unified AS (
    -- exp_avtaler branch (booked appointments)
    SELECT
        'exp_avtaler'                                      AS source_origin,
        TRY_CAST(a.pk_avtale_id AS VARCHAR(64))           AS source_record_id,
        'booked'                                           AS appointment_record_type,
        a.fk_person_id                                     AS fk_patient,
        CAST(NULL AS VARCHAR(50))                         AS patient_archive_number,
        a.date_business                                    AS appointment_date,
        TRY_CAST(a.start_time AS VARCHAR(50))             AS start_time,
        TRY_CAST(a.end_time AS VARCHAR(50))               AS end_time,
        CAST(NULL AS BIGINT)                               AS duration,
        TRY_CAST(a.appointment_type AS VARCHAR(100))      AS appointment_type,
        TRY_CAST(a.title AS VARCHAR(255))                 AS appointment_title,
        CAST(NULL AS BIGINT)                               AS fk_employee_responsible,
        TRY_CAST(a.employee_name AS VARCHAR(255))         AS responsible_employee_name,
        CAST(NULL AS BIGINT)                               AS fk_employee_performing,
        CAST(NULL AS INT)                                  AS employee_count,
        CAST(NULL AS VARCHAR(255))                        AS employee_initials,
        TRY_CAST(a.location AS VARCHAR(255))              AS location_name,
        CAST(NULL AS VARCHAR(64))                         AS fk_sted_id,
        CAST(NULL AS VARCHAR(64))                         AS fk_avdeling_id,
        CAST(NULL AS VARCHAR(255))                        AS department_name,
        CAST(NULL AS DATETIME2(6))                         AS arrived_at,
        CAST(NULL AS DATETIME2(6))                         AS checked_out_at,
        CAST(NULL AS DATETIME2(6))                         AS did_not_arrive_at,
        CAST(NULL AS VARCHAR(50))                         AS attendance_status,
        a.created_at,
        a.created_by,
        a.modified_at,
        a.modified_by
    FROM avtaler a

    UNION ALL

    -- statevent branch (occurred visit events)
    SELECT
        'statevent'                                        AS source_origin,
        TRY_CAST(e.pk_event_id AS VARCHAR(64))            AS source_record_id,
        'occurred'                                         AS appointment_record_type,
        e.fk_pasient_id                                    AS fk_patient,
        TRY_CAST(e.patient_archive_number AS VARCHAR(50)) AS patient_archive_number,
        e.event_date                                       AS appointment_date,
        TRY_CAST(e.start_time AS VARCHAR(50))             AS start_time,
        TRY_CAST(e.end_time AS VARCHAR(50))               AS end_time,
        TRY_CAST(e.duration AS BIGINT)                     AS duration,
        TRY_CAST(e.calc_consultation_type AS VARCHAR(100)) AS appointment_type,
        CAST(NULL AS VARCHAR(255))                        AS appointment_title,
        TRY_CAST(e.fk_ansvarlig_medarbeider_id AS BIGINT)  AS fk_employee_responsible,
        CAST(NULL AS VARCHAR(255))                        AS responsible_employee_name,
        TRY_CAST(e.fk_medarbeider_id AS BIGINT)            AS fk_employee_performing,
        TRY_CAST(e.employee_count AS INT)                  AS employee_count,
        TRY_CAST(e.employee_initials AS VARCHAR(255))     AS employee_initials,
        TRY_CAST(e.location AS VARCHAR(255))              AS location_name,
        TRY_CAST(e.fk_sted_id AS VARCHAR(64))             AS fk_sted_id,
        TRY_CAST(e.fk_avdeling_id AS VARCHAR(64))         AS fk_avdeling_id,
        TRY_CAST(e.department AS VARCHAR(255))            AS department_name,
        e.arrived_at,
        e.checked_out_at,
        e.did_not_arrive_at,
        CASE
            WHEN e.did_not_arrive_at IS NOT NULL THEN 'did_not_arrive'
            WHEN e.checked_out_at IS NOT NULL THEN 'checked_out'
            WHEN e.arrived_at IS NOT NULL THEN 'arrived'
            ELSE NULL
        END                                                AS attendance_status,
        e.created_at,
        e.created_by,
        e.modified_at,
        e.modified_by
    FROM event e
)

SELECT *
FROM unified
