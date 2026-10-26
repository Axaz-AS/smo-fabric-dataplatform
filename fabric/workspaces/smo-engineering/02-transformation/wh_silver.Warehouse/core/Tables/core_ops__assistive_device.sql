CREATE TABLE [core].[core_ops__assistive_device] (
    [pk_assistive_device_id]              VARCHAR (64)  NULL,
    [fk_patient]                          VARCHAR (64)  NULL,
    [fk_nav_decision]                     VARCHAR (64)  NULL,
    [vedtak_id]                           VARCHAR (64)  NULL,
    [fag_code]                            VARCHAR (50)  NULL,
    [production_method_code]              VARCHAR (50)  NULL,
    [name]                                VARCHAR (255) NULL,
    [icd10_code]                          VARCHAR (50)  NULL,
    [icd10_description]                   VARCHAR (255) NULL,
    [nomenclature_main_group_code]        VARCHAR (50)  NULL,
    [nomenclature_main_group_description] VARCHAR (255) NULL,
    [nomenclature_product_code]           VARCHAR (50)  NULL,
    [nomenclature_product_description]    VARCHAR (255) NULL,
    [clinical_cause_of_need]              VARCHAR (255) NULL,
    [clinical_injury_level]               VARCHAR (100) NULL,
    [clinical_injury_type]                VARCHAR (100) NULL,
    [clinical_injury_side]                VARCHAR (50)  NULL,
    [clinical_occupational_injury]        VARCHAR (50)  NULL,
    [created_at]                          DATETIME2 (6) NULL,
    [created_by]                          VARCHAR (100) NULL,
    [modified_at]                         DATETIME2 (6) NULL,
    [modified_by]                         VARCHAR (100) NULL
);


GO