CREATE TABLE [core].[core_ops__cast_archive] (
    [pk_cast_archive_id] VARCHAR (64)  NULL,
    [fk_patient]         VARCHAR (64)  NULL,
    [cast_category]      VARCHAR (100) NULL,
    [cast_location]      VARCHAR (100) NULL,
    [order_number]       VARCHAR (50)  NULL,
    [date_to_storage]    DATE          NULL,
    [date_discard]       DATE          NULL,
    [created_at]         DATETIME2 (6) NULL,
    [created_by]         VARCHAR (100) NULL,
    [modified_at]        DATETIME2 (6) NULL,
    [modified_by]        VARCHAR (100) NULL
);


GO