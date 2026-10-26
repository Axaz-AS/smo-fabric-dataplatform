CREATE TABLE [core].[core_ops__patient_contact] (
    [pk_patient_contact_id] VARCHAR (64)  NULL,
    [fk_patient]            VARCHAR (64)  NULL,
    [contact_type]          VARCHAR (50)  NULL,
    [contact_value]         VARCHAR (255) NULL,
    [is_sms_enabled]        BIT           NULL,
    [created_at]            DATETIME2 (6) NULL,
    [created_by]            VARCHAR (100) NULL,
    [modified_at]           DATETIME2 (6) NULL,
    [modified_by]           VARCHAR (100) NULL
);


GO