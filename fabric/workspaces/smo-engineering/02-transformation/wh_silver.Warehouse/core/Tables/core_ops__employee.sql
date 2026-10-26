CREATE TABLE [core].[core_ops__employee] (
    [pk_employee_id]        VARCHAR (64)  NULL,
    [username]              VARCHAR (100) NULL,
    [first_name]            VARCHAR (100) NULL,
    [last_name]             VARCHAR (100) NULL,
    [full_name]             VARCHAR (255) NULL,
    [abbreviation]          VARCHAR (50)  NULL,
    [job_title]             VARCHAR (100) NULL,
    [resource_type]         VARCHAR (100) NULL,
    [department_name]       VARCHAR (100) NULL,
    [storage_location]      VARCHAR (100) NULL,
    [email]                 VARCHAR (255) NULL,
    [address_line_1]        VARCHAR (255) NULL,
    [address_line_2]        VARCHAR (255) NULL,
    [postal_code]           VARCHAR (20)  NULL,
    [city]                  VARCHAR (100) NULL,
    [country]               VARCHAR (100) NULL,
    [is_active]             BIT           NULL,
    [source_system_profile] VARCHAR (50)  NULL,
    [created_at]            DATETIME2 (6) NULL,
    [modified_at]           DATETIME2 (6) NULL
);


GO