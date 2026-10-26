CREATE TABLE [mart].[fct_ops_lop_order] (
    [pk_order_id]                    VARCHAR (64)  NULL,
    [order_number]                   VARCHAR (50)  NULL,
    [fk_patient]                     VARCHAR (64)  NULL,
    [patient_number]                 VARCHAR (50)  NULL,
    [fk_employee_engineer]           VARCHAR (64)  NULL,
    [fk_employee_production_manager] VARCHAR (64)  NULL,
    [fk_health_personnel_rekvirent]  VARCHAR (64)  NULL,
    [fk_primary_nomenclature]        VARCHAR (64)  NULL,
    [fk_assistive_device]            VARCHAR (64)  NULL,
    [fk_nav_decision]                VARCHAR (64)  NULL,
    [department_name]                VARCHAR (100) NULL,
    [location_name]                  VARCHAR (100) NULL,
    [order_type]                     VARCHAR (50)  NULL,
    [order_status]                   VARCHAR (100) NULL,
    [is_in_production]               BIT           NULL,
    [is_urgent]                      BIT           NULL,
    [is_cancelled]                   BIT           NULL,
    [order_date]                     DATE          NULL,
    [planned_delivery_date]          DATE          NULL,
    [delivery_date]                  DATE          NULL,
    [trial_date]                     DATE          NULL,
    [completed_date]                 DATE          NULL,
    [source_origin]                  VARCHAR (20)  NULL,
    [created_at]                     DATETIME2 (6) NULL,
    [modified_at]                    DATETIME2 (6) NULL
);


GO