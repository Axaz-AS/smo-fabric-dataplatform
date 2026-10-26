CREATE TABLE [core].[core_ops__invoice_line] (
    [pk_invoice_line_id] VARCHAR (64)   NULL,
    [fk_invoice_id]      VARCHAR (64)   NULL,
    [quantity]           FLOAT (53)     NULL,
    [description]        VARCHAR (4000) NULL,
    [unit_price]         FLOAT (53)     NULL,
    [line_amount]        FLOAT (53)     NULL,
    [line_amount_vat]    FLOAT (53)     NULL,
    [accounting]         VARCHAR (100)  NULL,
    [vat_type]           VARCHAR (50)   NULL,
    [line_type]          VARCHAR (50)   NULL,
    [created_at]         DATETIME2 (6)  NULL,
    [created_by]         VARCHAR (100)  NULL,
    [modified_at]        DATETIME2 (6)  NULL,
    [modified_by]        VARCHAR (100)  NULL
);


GO