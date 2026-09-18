create view [int].[int_ops__employee_unified] as /*
    Model: int_ops__employee_unified
    Domain: Operations (Ops)
    Grain: 1 row per employee / clinician / staff member (person_id)

    Business Logic & Assumptions:
    - Unifies internal employees from the new master export (exp_medarbeider) and
      the legacy clinician statistics table (statkliniker).
    - Filters out clinic consultation and meeting rooms (employee_resource_type = 'Rom')
      present in statkliniker so only human personnel are included.
    - exp_medarbeider is the primary master for employee attributes (full name, email,
      job title, address, etc.), but currently contains sample data.
    - statkliniker contains the full historical clinician population, providing display name,
      resource type, and department fallback where exp_medarbeider has not yet exported the employee.
    - Periodic metrics and budget counts from statkliniker are excluded here; they belong
      in downstream fact/mart models rather than the employee entity.
*/

WITH medarbeider AS (
    SELECT * FROM [wh_silver].[int].[base_nobs__exp_medarbeider]
),

kliniker AS (
    SELECT * FROM [wh_silver].[int].[base_nobs__statkliniker]
    WHERE COALESCE(employee_resource_type, '') <> 'Rom'
),

all_persons AS (
    SELECT pk_medarbeider_id AS person_id FROM medarbeider
    UNION
    SELECT fk_person_id AS person_id FROM kliniker WHERE fk_person_id IS NOT NULL
),

unified AS (
    SELECT
        p.person_id                                        AS pk_employee_id,
        COALESCE(m.username, k.user_id)                    AS username,
        m.first_name,
        m.last_name,
        COALESCE(m.full_name, k.employee_display_name)     AS full_name,
        m.abbreviation,
        m.title                                            AS job_title,
        COALESCE(m.resource_type, k.employee_resource_type) AS resource_type,
        COALESCE(m.department, k.department_name)          AS department_name,
        m.storage_location,
        m.email,
        m.address_line_1,
        m.address_line_2,
        m.postal_code,
        m.city,
        m.country,
        COALESCE(k.is_active, 1)                           AS is_active,
        CASE
            WHEN m.pk_medarbeider_id IS NOT NULL THEN 'exp_medarbeider'
            ELSE 'statkliniker_fallback'
        END                                                AS source_system_profile,
        COALESCE(m.created_at, k.created_at)               AS created_at,
        COALESCE(m.modified_at, k.modified_at)             AS modified_at
    FROM all_persons p
    LEFT JOIN medarbeider m ON p.person_id = m.pk_medarbeider_id
    LEFT JOIN kliniker k ON p.person_id = k.fk_person_id
)

SELECT *
FROM unified;

GO