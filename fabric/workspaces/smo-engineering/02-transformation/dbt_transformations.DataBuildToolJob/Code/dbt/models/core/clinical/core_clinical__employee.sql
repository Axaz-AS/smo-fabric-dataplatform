/*
    Model: core_clinical__employee
    Domain: Clinical
    Grain: 1 row per internal Sophies Minde employee (pk_employee_id)

    Business Logic:
    - Represents internal Sophies Minde staff (orthopedic engineers, technicians,
      administrative staff, and leadership).
    - Unifies the rich master attributes from exp_medarbeider with full legacy population
      coverage from statkliniker.
*/

WITH unified AS (
    SELECT * FROM {{ ref('int_clinical__employee_unified') }}
)

SELECT
    pk_employee_id,
    username,
    first_name,
    last_name,
    full_name,
    abbreviation,
    job_title,
    resource_type,
    department_name,
    storage_location,
    email,
    address_line_1,
    address_line_2,
    postal_code,
    city,
    country,
    is_active,
    source_system_profile,
    created_at,
    modified_at
FROM unified
