WITH source AS (
    SELECT * FROM {{ source('nobs', 'exp_time') }}
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_time_entry_id,
        [_kflt_Ordre]                                      AS fk_order_id,
        [_kflt_MedarbeiderID]                              AS fk_employee_id,
        TRY_CAST([Dato] AS DATE)                           AS entry_date,
        [Produksjonsstatus]                                AS production_status,
        TRY_CAST([Timer] AS FLOAT)                         AS hours,
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
WHERE (is_deleted = 0 OR is_deleted IS NULL)
