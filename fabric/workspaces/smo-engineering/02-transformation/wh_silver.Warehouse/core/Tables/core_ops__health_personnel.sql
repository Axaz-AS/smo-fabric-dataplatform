CREATE TABLE [core].[core_ops__health_personnel] (
    [pk_health_personnel_id] VARCHAR (8000) NULL,
    [hpr_number]             VARCHAR (8000) NULL,
    [first_name]             VARCHAR (8000) NULL,
    [last_name]              VARCHAR (8000) NULL,
    [full_name]              VARCHAR (8000) NULL,
    [practitioner_category]  VARCHAR (8000) NULL,
    [profession]             VARCHAR (8000) NULL,
    [created_at]             DATETIME2 (6)  NULL,
    [created_by]             VARCHAR (8000) NULL,
    [modified_at]            DATETIME2 (6)  NULL,
    [modified_by]            VARCHAR (8000) NULL
);


GO