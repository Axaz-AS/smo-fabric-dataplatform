create view [int].[base_nobs__exp_ordrehistorikk] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_ordrehistorikk
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_order_history_id,
        [_kflt_Ordre]                                      AS fk_order_id,
        TRY_CAST([Dato] AS DATE)                           AS event_date,
        [Produksjonsstatus]                                AS production_status,
        [Stadie]                                           AS stage,
        [_kflt_MedarbeiderID]                              AS fk_employee_id,
        [_kflt_OrtopediingeniøransvarligID]                AS fk_orthopedic_engineer_id,
        [_klft_ProduksjonsAnsvarligID]                     AS fk_production_manager_id,
        [_klft_ProduksjonsStatusAnsvarligID]               AS fk_production_status_manager_id,
        TRY_CAST([zz__IsDeleted] AS INT)                   AS is_deleted,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2(6)) AS created_at,
        [zz__Creation_AccountName__lxt]                    AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2(6)) AS modified_at,
        [zz__Modification_AccountName__lxt]                AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2(6))      AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE (is_deleted = 0 OR is_deleted IS NULL);

GO