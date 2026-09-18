CREATE TABLE [core].[core_ops__journal] (
    [pk_journal_id]     VARCHAR (8000) NULL,
    [fk_patient]        VARCHAR (8000) NULL,
    [fk_order]          VARCHAR (8000) NULL,
    [journal_date]      DATE           NULL,
    [epj_document_type] VARCHAR (8000) NULL,
    [case_type]         VARCHAR (8000) NULL,
    [journal_text]      VARCHAR (8000) NULL,
    [created_by_user]   VARCHAR (8000) NULL,
    [created_at]        DATETIME2 (6)  NULL,
    [created_by]        VARCHAR (8000) NULL,
    [modified_at]       DATETIME2 (6)  NULL,
    [modified_by]       VARCHAR (8000) NULL
);


GO