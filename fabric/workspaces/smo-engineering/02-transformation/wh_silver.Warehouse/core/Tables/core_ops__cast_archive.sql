CREATE TABLE [core].[core_ops__cast_archive] (
    [pk_cast_archive_id] VARCHAR (8000) NULL,
    [fk_patient]         VARCHAR (8000) NULL,
    [cast_category]      VARCHAR (8000) NULL,
    [cast_location]      VARCHAR (8000) NULL,
    [order_number]       VARCHAR (8000) NULL,
    [date_to_storage]    DATE           NULL,
    [date_discard]       DATE           NULL,
    [created_at]         DATETIME2 (6)  NULL,
    [created_by]         VARCHAR (8000) NULL,
    [modified_at]        DATETIME2 (6)  NULL,
    [modified_by]        VARCHAR (8000) NULL
);


GO