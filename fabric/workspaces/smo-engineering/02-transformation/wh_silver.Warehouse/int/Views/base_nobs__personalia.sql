create view [int].[base_nobs__personalia] as WITH source AS (
    SELECT * FROM lh_bronze.nobs.exp_personalia
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_personalia_id,
        [_kflt_Person]                                     AS fk_person_id,
        [_kflt_Ergoterapeut]                               AS fk_ergoterapeut_id,
        [_kflt_Fastlege]                                   AS fk_fastlege_id,
        [_kflt_Fysioterapeut]                              AS fk_fysioterapeut_id,
        [_kflt_HenvisendeLege]                             AS fk_henvisende_lege_id,
        [_kflt_Ortopediingeniør]                           AS fk_ortopediingenior_id,
        [_kflt_Rekvirent]                                  AS fk_rekvirent_id,
        [_kflt_StedID]                                     AS fk_sted_id,
        [Pasientnummer]                                    AS patient_number,
        [Pasientstatus]                                    AS patient_status,
        [Fødselsnummer]                                    AS national_id_number,
        TRY_CAST([Fødselsdato] AS DATE)                    AS birth_date,
        [Kjønn]                                            AS gender,
        [Kommunenummer]                                    AS municipality_code,
        [Fylke]                                            AS county,
        [BySted]                                           AS city_place,
        [Avdeling]                                         AS department,
        [Møtested]                                         AS meeting_place,
        [Institusjon]                                      AS institution,
        [Kundenummer_NAV]                                  AS nav_customer_number,
        [BHT_Ergoterapeut]                                 AS bht_ergoterapeut,
        [BHT_Fastlege]                                     AS bht_fastlege,
        [BHT_Fysioterapeut]                                AS bht_fysioterapeut,
        [BHT_Ingeniør]                                     AS bht_ingenior,
        [BHT_KoordinerendeBehandler]                       AS bht_koordinerende_behandler,
        [BHT_Rekvirent]                                    AS bht_rekvirent,
        [KLI_Aktivitetsnivå]                               AS clinical_activity_level,
        [KLI_Behandlingsrisiko]                            AS clinical_treatment_risk,
        TRY_CAST([KLI_Høyde] AS INT)                       AS clinical_height_cm,
        TRY_CAST([KLI_Vekt] AS INT)                        AS clinical_weight_kg,
        [KLI_Kommunikasjonsbehov]                          AS clinical_communication_needs,
        [KLI_SpesielleObservasjoner]                       AS clinical_special_observations,
        [Kommunikasjonsbehov]                              AS communication_needs,
        [Oppfølgingsmåte]                                  AS followup_method,
        [Oppmøtebehov]                                     AS attendance_needs,
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