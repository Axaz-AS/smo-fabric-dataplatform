create view [int].[base_nobs__event] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.statevent
),

renamed AS (
    SELECT
        [__kplt__ID]                                        AS pk_event_id,
        [_kflt_AvdelingID]                                  AS fk_avdeling_id,
        [_kflt_MedarbeiderID]                               AS fk_medarbeider_id,
        [_kflt_MedarbeiderID_ansvarlig]                     AS fk_ansvarlig_medarbeider_id,
        [_kflt_PasientID]                                   AS fk_pasient_id,
        [_kflt_Sted]                                        AS fk_sted_id,
        [PasientArkivnr]                                    AS patient_archive_number,
        [Konsultasjonstype__lct]                            AS consultation_type,
        [Type__lct]                                         AS type,
        [AntallMedarbeidere]                                AS employee_count,
        [_kflt_MedarbeiderInitialer]                        AS employee_initials,
        TRY_CAST([Dato] AS DATE)                            AS event_date,
        [TimeStart]                                         AS start_time,
        [TimeEnd]                                           AS end_time,
        [Varighet]                                          AS duration,
        TRY_CAST([Is_HasArrivedTimeStamp] AS DATETIME2(6))     AS arrived_at,
        TRY_CAST([Is_HasCheckedOutTimeStamp] AS DATETIME2(6))  AS checked_out_at,
        TRY_CAST([Is_DidNotArriveTimeStamp] AS DATETIME2(6))   AS did_not_arrive_at,
        [Avdeling]                                          AS department,
        [Sted]                                              AS location,
        [_kalt_KonsultasjonType]                            AS calc_consultation_type,
        [_kalt_Type]                                        AS calc_type,
        TRY_CAST([zz__IsDeleted] AS INT)                    AS is_deleted,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2(6)) AS created_at,
        [zz__Creation_AccountName__lxt]                     AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2(6)) AS modified_at,
        [zz__Modification_AccountName__lxt]                 AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2(6))       AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE is_deleted = 0 OR is_deleted IS NULL;

GO