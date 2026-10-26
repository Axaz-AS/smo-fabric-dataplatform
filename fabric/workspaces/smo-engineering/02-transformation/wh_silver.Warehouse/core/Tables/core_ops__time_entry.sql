CREATE TABLE [core].[core_ops__time_entry] (
    [pk_time_entry_id]  VARCHAR (64)  NULL,
    [fk_order_id]       VARCHAR (64)  NULL,
    [fk_employee_id]    VARCHAR (64)  NULL,
    [entry_date]        DATE          NULL,
    [production_status] VARCHAR (50)  NULL,
    [hours]             FLOAT (53)    NULL,
    [created_at]        DATETIME2 (6) NULL,
    [created_by]        VARCHAR (100) NULL,
    [modified_at]       DATETIME2 (6) NULL,
    [modified_by]       VARCHAR (100) NULL
);


GO