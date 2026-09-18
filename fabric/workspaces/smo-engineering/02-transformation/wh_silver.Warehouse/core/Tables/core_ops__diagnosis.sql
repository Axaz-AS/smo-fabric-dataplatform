CREATE TABLE [core].[core_ops__diagnosis] (
    [pk_diagnosis_id]              VARCHAR (8000) NULL,
    [fk_patient]                   VARCHAR (8000) NULL,
    [diagnosis_type_code]          VARCHAR (8000) NULL,
    [diagnosis]                    VARCHAR (8000) NULL,
    [diagnosis_display]            VARCHAR (8000) NULL,
    [clinical_aid_type]            VARCHAR (8000) NULL,
    [clinical_info_line]           VARCHAR (8000) NULL,
    [clinical_injury_level]        VARCHAR (8000) NULL,
    [clinical_injury_side]         VARCHAR (8000) NULL,
    [clinical_injury_type]         VARCHAR (8000) NULL,
    [clinical_wound]               VARCHAR (8000) NULL,
    [clinical_wound_location]      VARCHAR (8000) NULL,
    [clinical_wound_location_date] DATE           NULL,
    [clinical_occupational_injury] VARCHAR (8000) NULL,
    [created_at]                   DATETIME2 (6)  NULL,
    [created_by]                   VARCHAR (8000) NULL,
    [modified_at]                  DATETIME2 (6)  NULL,
    [modified_by]                  VARCHAR (8000) NULL
);


GO