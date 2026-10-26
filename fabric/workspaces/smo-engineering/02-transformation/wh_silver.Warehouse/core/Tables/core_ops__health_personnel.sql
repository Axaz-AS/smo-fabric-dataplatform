CREATE TABLE [core].[core_ops__health_personnel] (
    [pk_health_personnel_id] VARCHAR (64)  NULL,
    [hpr_number]             VARCHAR (50)  NULL,
    [first_name]             VARCHAR (100) NULL,
    [last_name]              VARCHAR (100) NULL,
    [full_name]              VARCHAR (255) NULL,
    [practitioner_category]  VARCHAR (100) NULL,
    [profession]             VARCHAR (100) NULL,
    [created_at]             DATETIME2 (6) NULL,
    [created_by]             VARCHAR (100) NULL,
    [modified_at]            DATETIME2 (6) NULL,
    [modified_by]            VARCHAR (100) NULL
);


GO