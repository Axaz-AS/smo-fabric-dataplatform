CREATE TABLE [core].[core_ops__nomenclature] (
    [pk_nomenclature_code]       VARCHAR (8000) NULL,
    [nobs_detail_id]             VARCHAR (8000) NULL,
    [nomenclature_category_code] VARCHAR (8000) NULL,
    [subject_area]               VARCHAR (8000) NULL,
    [product_group]              VARCHAR (8000) NULL,
    [product_sub_group]          VARCHAR (8000) NULL,
    [description]                VARCHAR (8000) NULL,
    [has_additional_codes]       INT            NULL,
    [price_group]                VARCHAR (8000) NULL,
    [order_type]                 VARCHAR (8000) NULL,
    [source_origin]              VARCHAR (14)   NOT NULL
);


GO