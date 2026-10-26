CREATE TABLE [core].[core_ops__order_history] (
    [pk_order_history_id]             VARCHAR (64)  NULL,
    [fk_order_id]                     VARCHAR (64)  NULL,
    [event_date]                      DATE          NULL,
    [production_status]               VARCHAR (50)  NULL,
    [stage]                           VARCHAR (50)  NULL,
    [fk_employee_id]                  VARCHAR (64)  NULL,
    [fk_orthopedic_engineer_id]       VARCHAR (64)  NULL,
    [fk_production_manager_id]        VARCHAR (64)  NULL,
    [fk_production_status_manager_id] VARCHAR (64)  NULL,
    [created_at]                      DATETIME2 (6) NULL,
    [created_by]                      VARCHAR (100) NULL,
    [modified_at]                     DATETIME2 (6) NULL,
    [modified_by]                     VARCHAR (100) NULL
);


GO