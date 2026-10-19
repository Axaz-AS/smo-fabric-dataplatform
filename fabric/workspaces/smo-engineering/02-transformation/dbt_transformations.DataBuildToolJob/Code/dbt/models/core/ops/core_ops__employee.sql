/*
    Model: core_ops__employee
    Domain: Operations (Ops)
    Grain: 1 row per internal Sophies Minde employee (pk_employee_id)

    Business Logic:
    - Represents internal Sophies Minde staff (orthopedic engineers, technicians,
      administrative staff, and leadership).
    - Excludes clinic consultation and meeting rooms (Rom) present in statkliniker.
    - Unifies the rich master attributes from exp_medarbeider with full legacy population
      coverage from statkliniker.
*/

WITH unified AS (
    SELECT * FROM {{ ref('int_ops__employee_unified') }}
)

SELECT
    CAST(pk_employee_id AS VARCHAR(64))                  AS pk_employee_id,
    CAST(username AS VARCHAR(100))                       AS username,
    CAST(first_name AS VARCHAR(100))                     AS first_name,
    CAST(last_name AS VARCHAR(100))                      AS last_name,
    CAST(full_name AS VARCHAR(255))                      AS full_name,
    CAST(abbreviation AS VARCHAR(50))                    AS abbreviation,
    CAST(job_title AS VARCHAR(100))                      AS job_title,
    CAST(resource_type AS VARCHAR(100))                  AS resource_type,
    CAST(department_name AS VARCHAR(100))                AS department_name,
    CAST(storage_location AS VARCHAR(100))               AS storage_location,
    CAST(email AS VARCHAR(255))                          AS email,
    CAST(address_line_1 AS VARCHAR(255))                 AS address_line_1,
    CAST(address_line_2 AS VARCHAR(255))                 AS address_line_2,
    CAST(postal_code AS VARCHAR(20))                     AS postal_code,
    CAST(city AS VARCHAR(100))                           AS city,
    CAST(country AS VARCHAR(100))                        AS country,
    CAST(is_active AS BIT)                               AS is_active,
    CAST(source_system_profile AS VARCHAR(50))           AS source_system_profile,
    TRY_CAST(created_at AS DATETIME2(6))                 AS created_at,
    TRY_CAST(modified_at AS DATETIME2(6))                AS modified_at
FROM unified
