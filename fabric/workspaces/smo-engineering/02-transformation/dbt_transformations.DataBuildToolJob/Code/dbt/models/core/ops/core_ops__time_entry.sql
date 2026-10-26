/*
    Model: core_ops__time_entry
    Domain: Operations (Ops)
    Grain: 1 row per time entry (pk_time_entry_id)

    Business Logic:
    - Conformed core entity for logged work hours from the NOBS exp_Time export:
      hours per date per employee per order, with the production status at
      entry time.
    - Sourced from base_nobs__exp_time.
    - fk_order_id references core_ops__order softly: the order core is scoped to
      stat_statistikk orders and does not cover every order referenced by time
      entries (same treatment as core_ops__order_line.fk_order).
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_time') }}
)

SELECT
    CAST(pk_time_entry_id AS VARCHAR(64))                  AS pk_time_entry_id,
    CAST(fk_order_id AS VARCHAR(64))                       AS fk_order_id,
    CAST(fk_employee_id AS VARCHAR(64))                    AS fk_employee_id,
    TRY_CAST(entry_date AS DATE)                           AS entry_date,
    CAST(production_status AS VARCHAR(50))                 AS production_status,
    TRY_CAST(hours AS FLOAT)                               AS hours,
    TRY_CAST(created_at AS DATETIME2(6))                    AS created_at,
    CAST(created_by AS VARCHAR(100))                       AS created_by,
    TRY_CAST(modified_at AS DATETIME2(6))                   AS modified_at,
    CAST(modified_by AS VARCHAR(100))                      AS modified_by
FROM source
