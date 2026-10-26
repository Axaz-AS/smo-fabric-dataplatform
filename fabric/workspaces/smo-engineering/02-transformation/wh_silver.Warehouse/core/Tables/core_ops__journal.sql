CREATE TABLE [core].[core_ops__journal] (
    [pk_journal_id]     VARCHAR (64)  NULL,
    [fk_patient]        VARCHAR (64)  NULL,
    [fk_order]          VARCHAR (64)  NULL,
    [journal_date]      DATE          NULL,
    [epj_document_type] VARCHAR (100) NULL,
    [case_type]         VARCHAR (100) NULL,
    [journal_text]      VARCHAR (MAX) NULL,
    [created_by_user]   VARCHAR (100) NULL,
    [created_at]        DATETIME2 (6) NULL,
    [created_by]        VARCHAR (100) NULL,
    [modified_at]       DATETIME2 (6) NULL,
    [modified_by]       VARCHAR (100) NULL
);


GO