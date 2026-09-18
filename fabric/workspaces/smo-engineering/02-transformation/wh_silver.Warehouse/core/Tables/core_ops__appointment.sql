CREATE TABLE [core].[core_ops__appointment] (
    [pk_appointment_id]         VARCHAR (200)  NULL,
    [source_origin]             VARCHAR (11)   NOT NULL,
    [source_record_id]          VARCHAR (64)   NULL,
    [appointment_record_type]   VARCHAR (8)    NOT NULL,
    [fk_patient]                VARCHAR (8000) NULL,
    [patient_archive_number]    VARCHAR (50)   NULL,
    [appointment_date]          DATE           NULL,
    [start_time]                VARCHAR (50)   NULL,
    [end_time]                  VARCHAR (50)   NULL,
    [duration]                  BIGINT         NULL,
    [appointment_type]          VARCHAR (100)  NULL,
    [appointment_title]         VARCHAR (255)  NULL,
    [fk_employee_responsible]   BIGINT         NULL,
    [responsible_employee_name] VARCHAR (255)  NULL,
    [fk_employee_performing]    BIGINT         NULL,
    [employee_count]            INT            NULL,
    [employee_initials]         VARCHAR (255)  NULL,
    [location_name]             VARCHAR (255)  NULL,
    [fk_sted_id]                VARCHAR (64)   NULL,
    [fk_avdeling_id]            VARCHAR (64)   NULL,
    [department_name]           VARCHAR (255)  NULL,
    [arrived_at]                DATETIME2 (6)  NULL,
    [checked_out_at]            DATETIME2 (6)  NULL,
    [did_not_arrive_at]         DATETIME2 (6)  NULL,
    [attendance_status]         VARCHAR (50)   NULL,
    [created_at]                DATETIME2 (6)  NULL,
    [created_by]                VARCHAR (8000) NULL,
    [modified_at]               DATETIME2 (6)  NULL,
    [modified_by]               VARCHAR (8000) NULL
);


GO