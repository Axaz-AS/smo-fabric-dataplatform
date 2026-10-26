/*
    Model: core_ops__order_history
    Domain: Operations (Ops)
    Grain: 1 row per order history event (pk_order_history_id)

    Business Logic:
    - Conformed core entity for order history / production stage events from the
      NOBS exp_Ordrehistorikk export: event date, production status, stage and
      the responsible employee / orthopedic engineer / production manager per
      event.
    - Sourced from base_nobs__exp_ordrehistorikk.
    - fk_order_id references core_ops__order softly: the order core is scoped to
      stat_statistikk orders and does not cover every order referenced by
      history events (same treatment as core_ops__order_line.fk_order).
*/

WITH source AS (
    SELECT * FROM {{ ref('base_nobs__exp_ordrehistorikk') }}
)

SELECT
    CAST(pk_order_history_id AS VARCHAR(64))               AS pk_order_history_id,
    CAST(fk_order_id AS VARCHAR(64))                       AS fk_order_id,
    TRY_CAST(event_date AS DATE)                           AS event_date,
    CAST(production_status AS VARCHAR(50))                 AS production_status,
    CAST(stage AS VARCHAR(50))                             AS stage,
    CAST(fk_employee_id AS VARCHAR(64))                    AS fk_employee_id,
    CAST(fk_orthopedic_engineer_id AS VARCHAR(64))         AS fk_orthopedic_engineer_id,
    CAST(fk_production_manager_id AS VARCHAR(64))          AS fk_production_manager_id,
    CAST(fk_production_status_manager_id AS VARCHAR(64))   AS fk_production_status_manager_id,
    TRY_CAST(created_at AS DATETIME2(6))                    AS created_at,
    CAST(created_by AS VARCHAR(100))                       AS created_by,
    TRY_CAST(modified_at AS DATETIME2(6))                   AS modified_at,
    CAST(modified_by AS VARCHAR(100))                      AS modified_by
FROM source
