CREATE TABLE [core].[core_ops__nomenclature] (
    [pk_nomenclature_code]       VARCHAR (64)  NULL,
    [nobs_detail_id]             VARCHAR (64)  NULL,
    [nomenclature_category_code] VARCHAR (50)  NULL,
    [subject_area]               VARCHAR (100) NULL,
    [product_group]              VARCHAR (255) NULL,
    [product_sub_group]          VARCHAR (255) NULL,
    [description]                VARCHAR (255) NULL,
    [has_additional_codes]       BIT           NULL,
    [price_group]                VARCHAR (50)  NULL,
    [order_type]                 VARCHAR (50)  NULL,
    [source_origin]              VARCHAR (50)  NULL
);


GO