CREATE TABLE [core].[core_ops__employee] (
    [pk_employee_id]        VARCHAR (8000) NULL,
    [username]              VARCHAR (8000) NULL,
    [first_name]            VARCHAR (8000) NULL,
    [last_name]             VARCHAR (8000) NULL,
    [full_name]             VARCHAR (8000) NULL,
    [abbreviation]          VARCHAR (8000) NULL,
    [job_title]             VARCHAR (8000) NULL,
    [resource_type]         VARCHAR (8000) NULL,
    [department_name]       VARCHAR (8000) NULL,
    [storage_location]      VARCHAR (8000) NULL,
    [email]                 VARCHAR (8000) NULL,
    [address_line_1]        VARCHAR (8000) NULL,
    [address_line_2]        VARCHAR (8000) NULL,
    [postal_code]           VARCHAR (8000) NULL,
    [city]                  VARCHAR (8000) NULL,
    [country]               VARCHAR (8000) NULL,
    [is_active]             INT            NULL,
    [source_system_profile] VARCHAR (21)   NOT NULL,
    [created_at]            DATETIME2 (6)  NULL,
    [modified_at]           DATETIME2 (6)  NULL
);


GO