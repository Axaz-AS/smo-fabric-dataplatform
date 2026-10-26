CREATE TABLE [core].[core_ops__nav_decision] (
    [pk_nav_decision_id]                 VARCHAR (64)  NULL,
    [source_origin]                      VARCHAR (50)  NULL,
    [source_record_id]                   VARCHAR (64)  NULL,
    [fk_patient]                         VARCHAR (64)  NULL,
    [fk_order]                           VARCHAR (64)  NULL,
    [fk_vedtak_id]                       VARCHAR (64)  NULL,
    [patient_number]                     VARCHAR (50)  NULL,
    [fk_avdeling_id]                     VARCHAR (64)  NULL,
    [fk_nomenclature]                    VARCHAR (64)  NULL,
    [decision_status]                    VARCHAR (100) NULL,
    [decision_type]                      VARCHAR (100) NULL,
    [date_decision]                      DATE          NULL,
    [date_sent_nav]                      DATE          NULL,
    [fk_vedtak_type_code]                VARCHAR (50)  NULL,
    [decision_name]                      VARCHAR (255) NULL,
    [decision_icd10_code]                VARCHAR (50)  NULL,
    [decision_extension_expiration_date] DATE          NULL,
    [renewal_expiration_date]            DATE          NULL,
    [renewal_status_text]                VARCHAR (100) NULL,
    [renewal_status_code]                VARCHAR (50)  NULL,
    [created_at]                         DATETIME2 (6) NULL,
    [created_by]                         VARCHAR (100) NULL,
    [modified_at]                        DATETIME2 (6) NULL,
    [modified_by]                        VARCHAR (100) NULL
);


GO