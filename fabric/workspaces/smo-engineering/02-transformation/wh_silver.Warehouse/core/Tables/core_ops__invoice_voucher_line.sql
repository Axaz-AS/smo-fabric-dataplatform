CREATE TABLE [core].[core_ops__invoice_voucher_line] (
    [pk_invoice_voucher_line_id] VARCHAR (64)  NULL,
    [fk_invoice_id]              VARCHAR (64)  NULL,
    [quantity]                   FLOAT (53)    NULL,
    [article_name_internal]      VARCHAR (255) NULL,
    [unit_price]                 FLOAT (53)    NULL,
    [line_amount]                FLOAT (53)    NULL,
    [created_at]                 DATETIME2 (6) NULL,
    [created_by]                 VARCHAR (100) NULL,
    [modified_at]                DATETIME2 (6) NULL,
    [modified_by]                VARCHAR (100) NULL
);


GO