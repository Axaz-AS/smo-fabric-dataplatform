CREATE TABLE [mart].[fct_ops_lop_appointment] (
    [pk_appointment_id]         VARCHAR (200) NULL,
    [source_origin]             VARCHAR (20)  NULL,
    [source_record_id]          VARCHAR (64)  NULL,
    [appointment_record_type]   VARCHAR (20)  NULL,
    [fk_patient]                VARCHAR (64)  NULL,
    [appointment_date]          DATE          NULL,
    [start_time]                VARCHAR (50)  NULL,
    [end_time]                  VARCHAR (50)  NULL,
    [duration]                  VARCHAR (50)  NULL,
    [duration_minutes]          INT           NULL,
    [appointment_type]          VARCHAR (100) NULL,
    [appointment_title]         VARCHAR (255) NULL,
    [fk_employee_responsible]   VARCHAR (64)  NULL,
    [responsible_employee_name] VARCHAR (255) NULL,
    [fk_employee_performing]    VARCHAR (64)  NULL,
    [employee_initials]         VARCHAR (255) NULL,
    [location_name]             VARCHAR (255) NULL,
    [department_name]           VARCHAR (255) NULL,
    [attendance_status]         VARCHAR (50)  NULL,
    [arrived_at]                DATETIME2 (6) NULL,
    [checked_out_at]            DATETIME2 (6) NULL,
    [did_not_arrive_at]         DATETIME2 (6) NULL,
    [created_at]                DATETIME2 (6) NULL,
    [modified_at]               DATETIME2 (6) NULL
);


GO