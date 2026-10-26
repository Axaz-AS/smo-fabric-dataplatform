CREATE TABLE [core].[core_ops__patient_guardian] (
    [pk_patient_guardian_id] VARCHAR (64)  NULL,
    [fk_patient]             VARCHAR (64)  NULL,
    [first_name]             VARCHAR (100) NULL,
    [last_name]              VARCHAR (100) NULL,
    [full_name]              VARCHAR (255) NULL,
    [phone_number]           VARCHAR (50)  NULL,
    [email]                  VARCHAR (255) NULL,
    [created_at]             DATETIME2 (6) NULL,
    [created_by]             VARCHAR (100) NULL,
    [modified_at]            DATETIME2 (6) NULL,
    [modified_by]            VARCHAR (100) NULL
);


GO