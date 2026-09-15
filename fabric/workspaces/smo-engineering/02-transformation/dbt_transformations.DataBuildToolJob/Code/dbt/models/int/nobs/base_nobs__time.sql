WITH source AS (
    SELECT * FROM {{ source('nobs', 'stattime') }}
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_time_stat_id,
        [_kplt_TimeID]                                     AS pk_time_id,
        [_kflt_AvdelingID]                                 AS fk_avdeling_id,
        [_kflt_MedarbeiderID]                              AS fk_medarbeider_id,
        [_kflt_OrdreID]                                    AS fk_ordre_id,
        [_kflt_Sted]                                       AS fk_sted_id,
        [_kflt_Ordrenr]                                    AS order_number,
        [NomenklaturKode]                                  AS nomenclature_code,
        [Produksjonsstatus]                                AS production_status,
        [Medarbeider_Navn]                                 AS employee_name,
        [Avdeling]                                         AS department_name,
        [Sted]                                             AS location_name,
        TRY_CAST([Dato] AS DATE)                           AS entry_date,
        [Aar]                                              AS year,
        [Maaned]                                           AS month,
        [Uke]                                              AS week,
        [Timer]                                            AS hours_total,
        [Timer_I]                                          AS hours_category_i,
        [Timer_K]                                          AS hours_category_k,
        [Timer_N]                                          AS hours_category_n,
        [Timer_R]                                          AS hours_category_r,
        [_kalt_AutTimer]                                   AS calc_auto_hours,
        [_kalt_MedarbeiderType]                            AS calc_employee_type,
        [_kalt_OrdreType]                                  AS calc_order_type,
        TRY_CAST([zz__IsDeleted] AS INT)                   AS is_deleted,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2) AS created_at,
        [zz__Creation_AccountName__lxt]                    AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2) AS modified_at,
        [zz__Modification_AccountName__lxt]                AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2)      AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE is_deleted = 0 OR is_deleted IS NULL
