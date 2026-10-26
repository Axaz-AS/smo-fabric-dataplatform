CREATE TABLE [mart].[dim_ops_lop_employee] (
    [pk_employee_id]        VARCHAR (64)  NULL,
    [username]              VARCHAR (100) NULL,
    [first_name]            VARCHAR (100) NULL,
    [last_name]             VARCHAR (100) NULL,
    [full_name]             VARCHAR (255) NULL,
    [job_title]             VARCHAR (100) NULL,
    [resource_type]         VARCHAR (100) NULL,
    [department_name]       VARCHAR (100) NULL,
    [storage_location]      VARCHAR (100) NULL,
    [email]                 VARCHAR (255) NULL,
    [is_active]             BIT           NULL,
    [source_system_profile] VARCHAR (50)  NULL,
    [created_at]            DATETIME2 (6) NULL,
    [modified_at]           DATETIME2 (6) NULL
);


GO