CREATE TABLE [core].[core_ops__patient_contact] (
    [pk_patient_contact_id] VARCHAR (8000) NULL,
    [fk_patient]            VARCHAR (8000) NULL,
    [contact_type]          VARCHAR (8000) NULL,
    [contact_value]         VARCHAR (8000) NULL,
    [is_sms_enabled]        INT            NULL,
    [created_at]            DATETIME2 (6)  NULL,
    [created_by]            VARCHAR (8000) NULL,
    [modified_at]           DATETIME2 (6)  NULL,
    [modified_by]           VARCHAR (8000) NULL
);


GO