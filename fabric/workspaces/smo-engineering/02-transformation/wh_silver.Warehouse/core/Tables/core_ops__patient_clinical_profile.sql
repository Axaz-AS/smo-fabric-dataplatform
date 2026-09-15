CREATE TABLE [core].[core_ops__patient_clinical_profile] (
    [pk_patient_clinical_profile_id]    VARCHAR (8000) NULL,
    [fk_patient]                        VARCHAR (8000) NULL,
    [clinical_activity_level]           VARCHAR (8000) NULL,
    [clinical_treatment_risk]           VARCHAR (8000) NULL,
    [clinical_height_cm]                INT            NULL,
    [clinical_weight_kg]                INT            NULL,
    [clinical_communication_needs]      VARCHAR (8000) NULL,
    [clinical_special_observations]     VARCHAR (8000) NULL,
    [communication_needs]               VARCHAR (8000) NULL,
    [followup_method]                   VARCHAR (8000) NULL,
    [attendance_needs]                  VARCHAR (8000) NULL,
    [bht_fastlege_notes]                VARCHAR (8000) NULL,
    [bht_fysioterapeut_notes]           VARCHAR (8000) NULL,
    [bht_ergoterapeut_notes]            VARCHAR (8000) NULL,
    [bht_ingenior_notes]                VARCHAR (8000) NULL,
    [bht_koordinerende_behandler_notes] VARCHAR (8000) NULL,
    [bht_rekvirent_notes]               VARCHAR (8000) NULL,
    [created_at]                        DATETIME2 (6)  NULL,
    [created_by]                        VARCHAR (8000) NULL,
    [modified_at]                       DATETIME2 (6)  NULL,
    [modified_by]                       VARCHAR (8000) NULL
);


GO