CREATE TABLE [core].[core_ops__diagnosis] (
    [pk_diagnosis_id]              VARCHAR (64)  NULL,
    [fk_patient]                   VARCHAR (64)  NULL,
    [diagnosis_type_code]          VARCHAR (50)  NULL,
    [diagnosis]                    VARCHAR (255) NULL,
    [diagnosis_display]            VARCHAR (255) NULL,
    [clinical_aid_type]            VARCHAR (100) NULL,
    [clinical_info_line]           VARCHAR (255) NULL,
    [clinical_injury_level]        VARCHAR (100) NULL,
    [clinical_injury_side]         VARCHAR (50)  NULL,
    [clinical_injury_type]         VARCHAR (100) NULL,
    [clinical_wound]               VARCHAR (100) NULL,
    [clinical_wound_location]      VARCHAR (255) NULL,
    [clinical_wound_location_date] DATE          NULL,
    [clinical_occupational_injury] VARCHAR (50)  NULL,
    [created_at]                   DATETIME2 (6) NULL,
    [created_by]                   VARCHAR (100) NULL,
    [modified_at]                  DATETIME2 (6) NULL,
    [modified_by]                  VARCHAR (100) NULL
);


GO