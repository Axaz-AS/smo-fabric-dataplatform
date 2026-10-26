create view [int].[base_nobs__exp_ordre] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_ordre
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_exp_ordre_id,
        [Ordrenummer]                                      AS order_number,
        [_kflt__Person]                                    AS fk_person_id,
        [_kflt_HjelpemiddelID]                             AS fk_hjelpemiddel_id,
        [_kflt_VedtakID]                                   AS fk_vedtak_id,
        [_kflt_OrtopediIngeniør]                           AS fk_ortopediingenior_id,
        [_kflt_Produksjonsansvarlig]                       AS fk_produksjonsansvarlig_id,
        [_kflt_ProduksjonStatusAnsvarlig]                  AS fk_produksjonsstatus_ansvarlig_id,
        [Avdeling]                                         AS department,
        [Sted]                                             AS location,
        [Produksjonsstatus]                                AS production_status,
        [Omfang]                                           AS scope_description,
        [LeveringsinfoMetode]                              AS delivery_method,
        [Ordreopplysninger]                                AS order_notes,
        [SamLeveringsinfo]                                 AS delivery_notes,
        [SamPrøvingsinfo]                                  AS trial_notes,
        TRY_CAST([PlanlagtLeveringsDato] AS DATE)          AS planned_delivery_date,
        TRY_CAST([Ferdigdato] AS DATE)                     AS completed_date,
        TRY_CAST([ProeveDato] AS DATE)                     AS trial_date,
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