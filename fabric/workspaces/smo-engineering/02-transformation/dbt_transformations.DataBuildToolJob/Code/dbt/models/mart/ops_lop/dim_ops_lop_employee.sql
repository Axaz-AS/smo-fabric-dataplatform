/*
    Model: dim_ops_lop_employee
    Domain: Operations (Ops) — Consumer: LOP (Sophies Minde migration import)
    Grain: 1 row per internal Sophies Minde employee (pk_employee_id)

    Business Logic:
    - Employee dimension for the LOP migration import data product.
    - LOP fetches employees from the datalake as JSON; this table is the source
      of that export. Field selection follows the NOBS-to-LOP mapping workbook:
      NOBS ID, full name, e-mail, user name, title, subject area, department
      and standard storage location.
    - Phone numbers are NOT included: NOBS export (exp_medarbeider) carries no
      phone field; LOP receives phones through the Entra ID user migration.
    - RBAC / permission attributes (component management, unlock flags, birth
      number visibility, etc.) are handled inside LOP and intentionally excluded.
    - Includes both active and historical employees: historical appointments
      and orders reference responsible employees that may no longer be active.
      is_active lets LOP filter if needed.
    - Draft scope: only 1 of ~304 employees currently carries the rich profile
      from the exp_medarbeider sample; the remainder fall back to statkliniker
      with display name, resource type and department only (see source_system_profile).
*/

WITH employees AS (
    SELECT * FROM {{ ref('core_ops__employee') }}
)

SELECT
    pk_employee_id,
    username,
    first_name,
    last_name,
    full_name,
    job_title,
    resource_type,
    department_name,
    storage_location,
    email,
    is_active,
    source_system_profile,
    created_at,
    modified_at
FROM employees
