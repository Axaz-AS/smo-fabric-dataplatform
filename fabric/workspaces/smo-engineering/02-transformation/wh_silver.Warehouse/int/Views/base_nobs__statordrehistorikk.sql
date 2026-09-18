create view [int].[base_nobs__statordrehistorikk] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.statordrehistorikk
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_ordrehistorikk_id,
        [_kflt_Ordre]                                      AS fk_ordre_id,
        [_kflt_MedarbeiderID]                              AS fk_medarbeider_id,
        [_kflt_ProduksjonsstatusID]                        AS fk_produksjonsstatus_id,
        [_kflt_ProduksjonStatusAnsvarligID]                AS fk_produksjonsstatus_ansvarlig_id,
        [_kflt_Ordrenr]                                    AS order_number,
        [Nomenklaturkode]                                  AS nomenclature_code,
        [Produksjonsstatus]                                AS production_status,
        [Stadie]                                           AS stage,
        TRY_CAST([Dato] AS DATE)                           AS date_start,
        TRY_CAST([DatoSlutt] AS DATE)                      AS date_end,
        [Aar]                                              AS year,
        [Maaned]                                           AS month,
        [Uke]                                              AS week,
        [Dager]                                            AS days_duration,
        [_kalt_Produksjonstid]                             AS calc_production_time,
        [_kalt_ProduksjonsOpphold]                         AS calc_production_hold,
        [_kalt_ProduksjonsOpphold_Eksternt]                AS calc_production_hold_external,
        [_kalt_ProduksjonsOpphold_Internt]                 AS calc_production_hold_internal,
        [_kalt_ProduksjonsOpphold_Pasienten]               AS calc_production_hold_patient,
        [_kalt_StadieID]                                   AS calc_stage_id,
        [_kalt_Type]                                       AS calc_type,
        TRY_CAST([zz__IsDeleted] AS INT)                   AS is_deleted,
        TRY_CAST([zz__IsLocked] AS INT)                    AS is_locked,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2(6)) AS created_at,
        [zz__Creation_AccountName__lxt]                    AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2(6)) AS modified_at,
        [zz__Modification_AccountName__lxt]                AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2(6))      AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE is_deleted = 0 OR is_deleted IS NULL;

GO