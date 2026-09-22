/*
    Model: dim_ops_lop_health_personnel
    Domain: Operations (Ops) — Consumer: LOP (Sophies Minde migration import)
    Grain: 1 row per external healthcare practitioner (pk_health_personnel_id)

    Business Logic:
    - Healthcare personnel dimension for the LOP migration import data product.
      LOP fetches healthcare personnel as JSON from the datalake; this table is
      the source of that export.
    - Field selection follows the NOBS-to-LOP mapping workbook: name, surname,
      HPR ID number, profession and category.
    - External practitioners (fastleger, rekvirenter, specialists) — NOT internal
      employees, who live in dim_ops_lop_employee.
    - Draft scope: exp_helsepersonell currently contains a 12-row sample
      (all 'Lege (Rekvirent)'); revisit coverage when the full export arrives.
*/

WITH health_personnel AS (
    SELECT * FROM {{ ref('core_ops__health_personnel') }}
)

SELECT
    pk_health_personnel_id,
    hpr_number,
    first_name,
    last_name,
    full_name,
    practitioner_category,
    profession,
    created_at,
    modified_at
FROM health_personnel
