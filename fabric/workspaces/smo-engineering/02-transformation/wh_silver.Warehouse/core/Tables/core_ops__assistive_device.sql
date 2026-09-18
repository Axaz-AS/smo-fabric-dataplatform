CREATE TABLE [core].[core_ops__assistive_device] (
    [pk_assistive_device_id]              VARCHAR (8000) NULL,
    [fk_patient]                          VARCHAR (8000) NULL,
    [vedtak_id]                           VARCHAR (8000) NULL,
    [fag_code]                            VARCHAR (8000) NULL,
    [production_method_code]              VARCHAR (8000) NULL,
    [name]                                VARCHAR (8000) NULL,
    [icd10_code]                          VARCHAR (8000) NULL,
    [icd10_description]                   VARCHAR (8000) NULL,
    [nomenclature_main_group_code]        VARCHAR (8000) NULL,
    [nomenclature_main_group_description] VARCHAR (8000) NULL,
    [nomenclature_product_code]           VARCHAR (8000) NULL,
    [nomenclature_product_description]    VARCHAR (8000) NULL,
    [clinical_cause_of_need]              VARCHAR (8000) NULL,
    [clinical_injury_level]               VARCHAR (8000) NULL,
    [clinical_injury_type]                VARCHAR (8000) NULL,
    [clinical_injury_side]                VARCHAR (8000) NULL,
    [clinical_occupational_injury]        VARCHAR (8000) NULL,
    [created_at]                          DATETIME2 (6)  NULL,
    [created_by]                          VARCHAR (8000) NULL,
    [modified_at]                         DATETIME2 (6)  NULL,
    [modified_by]                         VARCHAR (8000) NULL
);


GO