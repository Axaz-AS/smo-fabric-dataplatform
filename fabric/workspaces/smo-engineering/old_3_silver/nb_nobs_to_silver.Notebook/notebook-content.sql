-- Fabric notebook source

-- METADATA ********************

-- META {
-- META   "kernel_info": {
-- META     "name": "synapse_pyspark"
-- META   },
-- META   "dependencies": {
-- META     "lakehouse": {
-- META       "default_lakehouse": "e34204fd-d37e-4e43-9b13-c1704b1d2a49",
-- META       "default_lakehouse_name": "lh_bronze",
-- META       "default_lakehouse_workspace_id": "0090292d-63b6-403d-b31a-2ae7358fc623",
-- META       "known_lakehouses": [
-- META         {
-- META           "id": "e34204fd-d37e-4e43-9b13-c1704b1d2a49"
-- META         },
-- META         {
-- META           "id": "53469948-0d7f-4073-91ff-570a9d25bec6"
-- META         }
-- META       ]
-- META     }
-- META   }
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_statistikk AS
SELECT
    -- Primary Key
    `__kplt__ID` AS pk_statistikk_id,
    
    -- Foreign Keys
    `_kflt_AvdelingID` AS fk_avdeling_id,
    `_kflt_FakturaID` AS fk_faktura_id,
    `_kflt_IngenioerID` AS fk_ingenioer_id,
    `_kflt_KundeID` AS fk_kunde_id,
    `_kflt_OrdreID` AS fk_ordre_id,
    `_kflt_OrdrehjelpemiddelID` AS fk_ordrehjelpemiddel_id,
    `_kflt_OrtokID` AS fk_ortok_id,
    `_kflt_PasientID` AS fk_pasient_id,
    `_kflt_Produksjonsansvarlig` AS fk_produksjonsansvarlig_id,
    `_kflt_Produksjonsstatus` AS fk_produksjonsstatus_id,
    `_kflt_RekvirentID` AS fk_rekvirent_id,
    `_kflt_StedID` AS fk_sted_id,
    
    -- Order Info
    OrdreNummer AS order_number,
    Fakturanummer AS invoice_number,
    CAST(CEIL(Antall) AS INT) AS quantity,
    Status_lct AS status,
    Nomenklaturkode AS nomenclature_code,
    HovedgruppeKode AS main_group_code,
    
    -- Dates
    TO_DATE(Dato_Ordredato, 'yyyy-MM-dd') AS order_date,
    TO_DATE(Dato_Levert, 'yyyy-MM-dd') AS delivery_date,
    TO_DATE(Dato_Faktura, 'yyyy-MM-dd') AS invoice_date,
    
    -- Production Days
    Dager_Fremstillingstid AS days_manufacturing,
    Dager_Produksjon AS days_production,
    Dager_Produksjonsopphold AS days_production_hold,
    
    -- Financial - Invoice
    FakturaSum AS invoice_total,
    FakturaSumEksMva AS invoice_total_ex_vat,
    
    -- Financial - Costs
    Kost_Arbeid AS cost_labor,
    Kost_Arbeid_Estimert AS cost_labor_estimated,
    Kost_Arbeid_Registrert AS cost_labor_registered,
    Kost_Fastpris AS cost_fixed_price,
    Kost_Fastpris_Estimert AS cost_fixed_price_estimated,
    Kost_Faststoenad AS cost_fixed_allowance,
    Kost_Faststoenad_Ink_EA_NAV AS cost_fixed_allowance_incl_nav,
    Kost_Faststoenad_Eks_EA_NAV AS cost_fixed_allowance_excl_nav,
    Kost_Materialer AS cost_materials,
    Kost_Materialer_Estimert AS cost_materials_estimated,
    Kost_Materialer_Registrert AS cost_materials_registered,
    Kost_Total AS cost_total,
    Kost_Total_Estimert AS cost_total_estimated,
    Kost_Total_Registrert AS cost_total_registered,
    
    -- Co-payment
    EB_Egenbetaling AS copay_amount,
    EB_EgenbetalingType AS copay_type,
    EB_Egenbetaling_Dekket_NAV AS copay_covered_nav,
    EB_Egenbetaling_Dekket_Pasient AS copay_covered_patient,
    
    -- Time Registration
    Tid_Timeantall1 AS hours_registered_1,
    Tid_Timeantall2 AS hours_registered_2,
    Tid_Timeantall_Estimert AS hours_estimated,
    Tid_Timeantall_Fast AS hours_fixed,
    Tid_Registrert_Timeantall1 AS hours_registered_timecount1,
    Tid_Registrert_001 AS hours_registered_001,
    Tid_Registrert_002 AS hours_registered_002,
    Tid_Registrert_003 AS hours_registered_003,
    Tid_Timeantall1_inklFastPris AS hours_incl_fixed_price,
    Timepris01 AS hourly_rate,
    
    -- Patient Info
    Pas_Pasientnr AS patient_number,
    Pas_Foedselsaar AS patient_birth_year,
    Pas_Kjoenn AS patient_gender,
    
    -- Location
    Avdeling_lct AS department,
    Sted_lct AS location,
    Sted_Fylke AS county,
    Sted_Kommune AS municipality,
    Sted_Postnr AS postal_code,
    Sted_Poststed AS postal_place,
    
    -- NAV
    NAVKontor_Nummer AS nav_office_number,
    
    -- Clinical
    Klinisk_AarsakBehov AS clinical_reason,
    Klinisk_ICD10 AS clinical_icd10,
    Fagomraade_lct AS specialty_area,
    
    -- Calculated Fields
    `_kalt_Fagomraade` AS calc_specialty_code,
    `_kalt_FakturaType` AS calc_invoice_type,
    `_kalt_Fakturert` AS calc_is_invoiced,
    `_kalt_KundeKategori` AS calc_customer_category,
    `_kalt_NomenklaturType` AS calc_nomenclature_type,
    `_kalt_OrdreType` AS calc_order_type,
    
    -- Flags
    `zz__AnnulertFlag` AS is_cancelled,
    `zz__FakturertFlag` AS is_invoiced,
    `zz__IProduksjonFlag` AS is_in_production,
    `zz__TilFaktureringFlag` AS is_ready_for_invoicing,
    `zz__IsDeleted` AS is_deleted,
    
    -- Metadata
    `zz__Creation_Timestamp__lxm` AS created_at,
    `zz__Creation_AccountName__lxt` AS created_by,
    `zz__Modification_Timestamp__lxm` AS modified_at,
    `zz__Modification_AccountName__lxt` AS modified_by,
    `_ingestion_timestamp` AS ingested_at

FROM lh_bronze.nobs.stat_statistikk

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_event AS
SELECT
    -- Primary Key
    `__kplt__ID` AS pk_event_id,

    -- Foreign Keys
    `_kflt_AvdelingID` AS fk_avdeling_id,
    `_kflt_MedarbeiderID` AS fk_medarbeider_id,
    `_kflt_MedarbeiderID_ansvarlig` AS fk_ansvarlig_medarbeider_id,
    `_kflt_PasientID` AS fk_pasient_id,
    `_kflt_Sted` AS fk_sted_id,

    -- Consultation Info
    PasientArkivnr AS patient_archive_number,
    Konsultasjonstype__lct AS consultation_type,
    Type__lct AS type,
    AntallMedarbeidere AS employee_count,
    `_kflt_MedarbeiderInitialer` AS employee_initials,

    -- Dates & Time
    CAST(Dato AS DATE) AS date,
    TimeStart AS start_time,
    TimeEnd AS end_time,
    Varighet AS duration,

    -- Attendance / Status Timestamps
    TO_TIMESTAMP(Is_HasArrivedTimeStamp, "yyyy-MM-dd'T'HH:mm:ssXXX") AS arrived_at,
    TO_TIMESTAMP(Is_HasCheckedOutTimeStamp, "yyyy-MM-dd'T'HH:mm:ssXXX") AS checked_out_at,
    TO_TIMESTAMP(Is_DidNotArriveTimeStamp, "yyyy-MM-dd'T'HH:mm:ssXXX") AS did_not_arrive_at,

    -- Location
    Avdeling AS department,
    Sted AS location,

    -- Calculated Fields
    `_kalt_KonsultasjonType` AS calc_consultation_type,
    `_kalt_Type` AS calc_type,

    -- Flags
    `zz__IsDeleted` AS is_deleted,

    -- Metadata
    `zz__Creation_Timestamp__lxm` AS created_at,
    `zz__Creation_AccountName__lxt` AS created_by,
    `zz__Modification_Timestamp__lxm` AS modified_at,
    `zz__Modification_AccountName__lxt` AS modified_by,
    `_ingestion_timestamp` AS ingested_at

FROM lh_bronze.nobs.statevent

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_kliniker AS
SELECT
    -- Primary Key
    `__kplt__ID` AS pk_kliniker_id,

    -- Foreign Keys
    `_kflt_AvdelingID` AS fk_avdeling_id,
    `_kflt_PersonID` AS fk_person_id,

    -- Clinician Info
    BrukerID AS user_id,
    Medarbeider_Visningsnavn_lct AS employee_display_name,
    Medarbeider_RessursType_lct AS employee_resource_type,
    Avdelingsnavn_lct AS department_name,
    Nomenklatur AS nomenclature,

    -- Appointment Counts (Historical)
    AntallAvtaler_HittilIAar AS count_appointments_ytd,
    AntallAvtaler_ForrigeMnd AS count_appointments_prev_month,
    AntallAvtaler_Forrige3Mnd AS count_appointments_prev_3_months,
    AntallAvtaler_Forrige6Mnd AS count_appointments_prev_6_months,
    AntallAvtaler_ForrigeUke AS count_appointments_prev_week,

    -- Appointment Counts (Future)
    Antall_Kommende1Mnd AS count_appointments_next_1_month, -- Note: mapped from Antall_Kommende1Mnd
    AntallAvtaler_Kommende2Mnd AS count_appointments_next_2_months,
    AntallAvtaler_Kommende3Mnd AS count_appointments_next_3_months,

    -- Order Counts
    Antall_ordre AS count_orders,
    Antall_ordre_typeK AS count_orders_type_k,
    Fak_Antall_ordre AS count_orders_invoiced,
    Fak_Antall_ordre_typeK AS count_orders_invoiced_type_k,

    -- Appointment Duration (Totals)
    VarighetAvtaler_HittilIAar AS duration_appointments_ytd,
    VarighetAvtaler_ForrigeMnd AS duration_appointments_prev_month,
    VarighetAvtaler_Forrige3Mnd AS duration_appointments_prev_3_months,
    VarighetAvtaler_Forrige6Mnd AS duration_appointments_prev_6_months,
    VarighetAvtaler_ForrigeUke AS duration_appointments_prev_week,
    VarighetAvtaler_Kommende1Mnd AS duration_appointments_next_1_month,
    VarighetAvtaler_Kommende2Mnd AS duration_appointments_next_2_months,
    VarighetAvtaler_Kommende3Mnd AS duration_appointments_next_3_months,

    -- Appointment Duration (Statistics: Avg/Max/Min)
    VarighetAvtaler_GjSnitt_HittilIAar AS duration_avg_ytd,
    VarighetAvtaler_GjSnitt_ForrigeMnd AS duration_avg_prev_month,
    VarighetAvtaler_GjSnitt_ForrigeUke AS duration_avg_prev_week,
    VarighetAvtaler_GjSnitt_Kommende3Mnd AS duration_avg_next_3_months,
    
    VarighetAvtaler_MAX_HittilIAar AS duration_max_ytd,
    VarighetAvtaler_MAX_ForrigeMnd AS duration_max_prev_month,
    VarighetAvtaler_MAX_ForrigeUke AS duration_max_prev_week,
    VarighetAvtaler_MAX_Kommende3Mnd AS duration_max_next_3_months,
    
    VarighetAvtaler_MIN_HittilIAar AS duration_min_ytd,
    VarighetAvtaler_MIN_ForrigeMnd AS duration_min_prev_month,
    VarighetAvtaler_MIN_ForrigeUke AS duration_min_prev_week,
    VarighetAvtaler_MIN_Kommende3Mnd AS duration_min_next_3_months,

    -- Financials: Totals (Sum)
    Sum_Total AS sum_total,
    Sum_Total_NAV AS sum_total_nav,
    Sum_FastPris AS sum_fixed_price,
    Sum_FastPris_typeK AS sum_fixed_price_type_k,
    Sum_FastStoenad AS sum_fixed_allowance,
    Sum_FastTid AS sum_fixed_time,
    Sum_TidVerdi AS sum_time_value,
    Sum_TidVerdi_lcn AS sum_time_value_local,

    -- Financials: Invoiced (Fak)
    SumFak_Total AS sum_invoiced_total,
    SumFak_Total_NAV AS sum_invoiced_total_nav,
    SumFak_FakturertTid AS sum_invoiced_time,
    SumFak_FastPris AS sum_invoiced_fixed_price,
    SumFak_FastPris_typeK AS sum_invoiced_fixed_price_type_k,
    SumFak_FastStoenad AS sum_invoiced_fixed_allowance,
    SumFak_FastTid AS sum_invoiced_fixed_time,
    SumFak_TidVerdi AS sum_invoiced_time_value,
    SumFak_TidVerdi_lcn AS sum_invoiced_time_value_local,

    -- Financials: Estimated
    Sum_EstimertTid AS sum_estimated_time,
    Sum_EstimertTid_Dag AS sum_estimated_time_day,
    Sum_EstimertTid_Uke AS sum_estimated_time_week,
    Sum_EstimertTid_Maaned AS sum_estimated_time_month,
    Sum_EstimertTid_K AS sum_estimated_time_k,
    Sum_EstimertTid_N AS sum_estimated_time_n,
    Sum_EstimertTid_R AS sum_estimated_time_r,

    -- Hours / Budget
    Budsjett_Timer AS budget_hours,
    Budsjett_Timer_Produsert AS budget_hours_produced,
    Timer AS hours_total,
    Timer_I AS hours_category_i,
    Timer_K AS hours_category_k,
    Timer_N AS hours_category_n,
    Timer_R AS hours_category_r,

    -- Trends / Development (Utvikling)
    Utvikling_Total AS trend_total,
    Utvikling_Sum_Total_NAV AS trend_total_nav,
    Utvikling_TidVerdi AS trend_time_value,
    Utvikling_FastPris AS trend_fixed_price,
    Utvikling_FastPris_typeK AS trend_fixed_price_type_k,
    Utvikling_FastStoenad AS trend_fixed_allowance,
    Utvikling_FastTid AS trend_fixed_time,
    Utvikling_EstimertTid AS trend_estimated_time,
    Utvikling_Antall_ordre AS trend_order_count,
    Utvikling_Antall_ordre_typeK AS trend_order_count_type_k,

    -- Trends / Development (Invoiced)
    Utvikling_SumFak_Total AS trend_invoiced_total,
    Utvikling_SumFak_Total_NAV AS trend_invoiced_total_nav,
    Utvikling_SumFak_TidVerdi AS trend_invoiced_time_value,
    Utvikling_SumFak_FakturertTid AS trend_invoiced_time,
    Utvikling_SumFak_FastPris AS trend_invoiced_fixed_price,
    Utvikling_SumFak_FastPris_typeK AS trend_invoiced_fixed_price_type_k,
    Utvikling_SumFak_FastStoenad AS trend_invoiced_fixed_allowance,
    Utvikling_SumFak_FastTid AS trend_invoiced_fixed_time,
    Utvikling_Fak_Antall_ordre AS trend_invoiced_order_count,
    Utvikling_Fak_Antall_ordre_typeK AS trend_invoiced_order_count_type_k,

    -- Reporting Period Definitions (Dates)
    Dato_fom AS report_date_from,
    Dato_tom AS report_date_to,
    Dato__Prev_fom AS report_prev_date_from,
    Dato__Prev_tom AS report_prev_date_to,
    
    Dato__DetteAarStart AS date_this_year_start,
    Dato__HittilIAarSlutt AS date_ytd_end,
    
    Dato__ForrigeMndStart AS date_prev_month_start,
    Dato__ForrigeMndSlutt AS date_prev_month_end,
    Dato__Forrige3MndStart AS date_prev_3_months_start,
    Dato__Forrige6MndStart AS date_prev_6_months_start,
    
    Dato__ForrigeUkeStart AS date_prev_week_start,
    Dato__ForrigeUkeSlutt AS date_prev_week_end,
    
    Dato__KommendeMndStart AS date_next_month_start,
    Dato__Kommende1MndSlutt AS date_next_1_month_end,
    Dato__Kommende2MndSlutt AS date_next_2_months_end,
    Dato__Kommende3MndSlutt AS date_next_3_months_end,

    -- Calculated Fields
    `_kalt_Fag` AS calc_subject,
    `_kalt_Fag_Hoved` AS calc_main_subject,
    `_kalt_ResourceType` AS calc_resource_type,
    `_kalt_Type` AS calc_type,

    -- Flags
    `zz__IsActive` AS is_active,
    `zz__IsDeleted` AS is_deleted,
    `zz__IsLocked` AS is_locked,

    -- Metadata
    `zz__Creation_Timestamp__lxm` AS created_at,
    `zz__Creation_AccountName__lxt` AS created_by,
    `zz__Modification_Timestamp__lxm` AS modified_at,
    `zz__Modification_AccountName__lxt` AS modified_by,
    `_ingestion_timestamp` AS ingested_at

FROM lh_bronze.nobs.statkliniker

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- MARKDOWN ********************

-- ## Nomenclature
-- 
-- The regex replace part is because of some new line characters causing issues. 

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_nomenclature AS (
    WITH nobs_nomenclature AS (
        SELECT
            NULLIF(REGEXP_REPLACE(Nomenklatur_Produkt_Kode, '[\\s\\r\\n\\t]+', ''), '')  AS Nomenklatur_Produkt_Kode,
            NomenklaturKode,
            __kplt__ID
        FROM lh_bronze.nobs.statnomenklatur_detail
        WHERE NULLIF(REGEXP_REPLACE(Nomenklatur_Produkt_Kode, '[\\s\\r\\n\\t]+', ''), '') IS NOT NULL
    ),

    nomenklatur_data AS (
        SELECT
            NULLIF(REGEXP_REPLACE(nomenklatur_kode, '[\\s\\r\\n\\t]+', ''), '')          AS nomenklatur_kode,
            hovedgruppe,
            `fagområde`,
            produktgrupper,
            beskrivelse2,
            nomenklatur_tekst,
            tilleggskoder,
            fastpris
        FROM lh_bronze.excel_mappings.nomenklatur
        WHERE NULLIF(REGEXP_REPLACE(nomenklatur_kode, '[\\s\\r\\n\\t]+', ''), '') IS NOT NULL
    )

    SELECT
        COALESCE(
            nn.Nomenklatur_Produkt_Kode,
            mn.nomenklatur_kode
        )                                               AS pk_nomenclature_code,
        mn.hovedgruppe                                  AS nomenclature_category_code,
        mn.`fagområde`                                  AS subject_area,
        mn.produktgrupper                               AS product_group,
        mn.beskrivelse2                                 AS product_sub_group,
        mn.nomenklatur_tekst                            AS description,
        CASE mn.tilleggskoder
            WHEN 'Nei' THEN FALSE
            WHEN 'Ja' THEN TRUE
            ELSE NULL
        END                                             AS has_additional_codes,
        mn.fastpris                                     AS price_group,
        nn.__kplt__ID                                   AS nobs_id
    FROM nobs_nomenclature AS nn
    FULL OUTER JOIN nomenklatur_data AS mn
        ON nn.Nomenklatur_Produkt_Kode = mn.nomenklatur_kode
)

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- MARKDOWN ********************

-- ## Nomeclature raw (temp)
-- 
-- Temporary passthrough of raw data for powerbi report lift and shift

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_nomenklatur_detail AS
SELECT
    -- Primary Key
    `__kplt__ID` AS pk_nomenklatur_detail_id,

    -- Foreign Keys
    `_kflt_AvdelingID` AS fk_avdeling_id,
    `_kflt_StedID` AS fk_sted_id,

    -- Nomenclature / Product Info
    NomenklaturKode AS nomenclature_code,
    Nomenklatur_Produkt_Kode AS product_code,
    Nomenklatur_Produkt_Navn__lct AS product_name,
    Nomenklatur_Produkt_Tekst AS product_description,
    
    -- Classification
    Ordretype AS order_type,
    
    -- Calculated Fields
    `_kalt_Status` AS calc_status,
    `_kalt_Type` AS calc_type,

    -- Flags
    `zz__IsDeleted` AS is_deleted,
    `zz__IsLocked` AS is_locked,

    -- Metadata
    `zz__Creation_Timestamp__lxm` AS created_at,
    `zz__Creation_AccountName__lxt` AS created_by,
    `zz__Modification_Timestamp__lxm` AS modified_at,
    `zz__Modification_AccountName__lxt` AS modified_by,
    `_ingestion_timestamp` AS ingested_at

FROM lh_bronze.nobs.statnomenklatur_detail

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- MARKDOWN ********************

-- #

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_ordrehistorikk AS
SELECT
    -- Primary Key
    `__kplt__ID` AS pk_ordrehistorikk_id,

    -- Foreign Keys
    `_kflt_Ordre` AS fk_ordre_id,
    `_kflt_MedarbeiderID` AS fk_medarbeider_id,
    `_kflt_ProduksjonsstatusID` AS fk_produksjonsstatus_id,
    `_kflt_ProduksjonStatusAnsvarligID` AS fk_produksjonsstatus_ansvarlig_id,

    -- Order Details
    `_kflt_Ordrenr` AS order_number,
    Nomenklaturkode AS nomenclature_code,
    Produksjonsstatus AS production_status,
    Stadie AS stage,

    -- Time Dimensions
    Dato AS date_start,
    DatoSlutt AS date_end,
    Aar AS year,
    Maaned AS month,
    Uke AS week,
    Dager AS days_duration,

    -- Calculated Metrics (Time/Hold)
    `_kalt_Produksjonstid` AS calc_production_time,
    `_kalt_ProduksjonsOpphold` AS calc_production_hold,
    `_kalt_ProduksjonsOpphold_Eksternt` AS calc_production_hold_external,
    `_kalt_ProduksjonsOpphold_Internt` AS calc_production_hold_internal,
    `_kalt_ProduksjonsOpphold_Pasienten` AS calc_production_hold_patient,
    
    -- Other Calculations
    `_kalt_StadieID` AS calc_stage_id,
    `_kalt_Type` AS calc_type,

    -- Flags
    `zz__IsDeleted` AS is_deleted,
    `zz__IsLocked` AS is_locked,

    -- Metadata
    `zz__Creation_Timestamp__lxm` AS created_at,
    `zz__Creation_AccountName__lxt` AS created_by,
    `zz__Modification_Timestamp__lxm` AS modified_at,
    `zz__Modification_AccountName__lxt` AS modified_by,
    `_ingestion_timestamp` AS ingested_at

FROM lh_bronze.nobs.statordrehistorikk

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_ordrelinje AS
SELECT
    -- Primary Key
    `__kplt_ID` AS pk_ordrelinje_id,

    -- Foreign Keys
    `_kflt_Ordre_ID` AS fk_ordre_id,
    `_kflt_Ordrelinje_ID` AS fk_parent_ordrelinje_id, -- Likely a reference to a parent line or grouping
    `_kflt_Komponent_ID` AS fk_komponent_id,
    `_kflt_Leverandoer_ID` AS fk_leverandoer_id,
    `_kflt_AvdelingID` AS fk_avdeling_id,
    `_kflt_Sted_ID` AS fk_sted_id,

    -- Order Info
    Ordenummer AS order_number,
    Status AS status,
    Produksjonsstatus AS production_status,
    NomenklaturKode AS nomenclature_code,
    Destinasjonskode AS destination_code,

    -- Quantity
    Antall AS quantity_ordered,
    AntallPlukket AS quantity_picked,

    -- Article / Product Info
    ArtikkelNummer_Intern AS article_number_internal,
    ArtikkelNummer_Lev AS article_number_supplier,
    ArtikkelBenevnelse_Intern AS article_name_internal,
    ArtikkelBenevnelse_Lev AS article_name_supplier,

    -- Supplier Info
    LeverandoerNr AS supplier_number,
    LeverandoerAdmNr AS supplier_admin_number,
    Leverandoernavn AS supplier_name,

    -- Financials - Unit Prices
    Enhetspris AS unit_price,
    Enhetspris_inn AS unit_price_in, -- Cost price
    Enhetspris_ut AS unit_price_out, -- Sales price

    -- Financials - Line Amounts
    LinjeBeloep AS line_amount,
    LinjeBeloepPlukket_inn AS line_amount_picked_in,
    LinjeBeloepPlukket_ut AS line_amount_picked_out,

    -- Invoice Info
    Fakturanummer AS invoice_number,
    EgenbetalingFakturanummer AS copay_invoice_number,

    -- Dates
    Ordredato AS order_date,
    RegistrertDato AS registered_date,
    BestiltDato AS ordered_from_supplier_date,
    PlukketDato AS picked_date,
    FakturaDato AS invoice_date,
    EgenbetalingFakturaDato AS copay_invoice_date,

    -- Location Names
    Avdeling AS department_name,
    StedNavn AS location_name,

    -- Flags
    `zz__IsDeleted` AS is_deleted,
    `zz__IsLocked` AS is_locked,

    -- Metadata
    `zz__Creation_Timestamp__lxm` AS created_at,
    `zz__Creation_AccountName__lxt` AS created_by,
    `zz__Modification_Timestamp__lxm` AS modified_at,
    `zz__Modification_AccountName__lxt` AS modified_by,
    `_ingestion_timestamp` AS ingested_at

FROM lh_bronze.nobs.statordrelinje

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_pasient_detail AS
SELECT
    -- Primary Key
    `__kplt__ID` AS pk_pasient_detail_id,

    -- Foreign Keys
    `_kflt_PersonID` AS fk_person_id,
    `_kflt_AvdelingID` AS fk_avdeling_id,
    `_kflt_StedID` AS fk_sted_id,

    -- Patient Info
    Pasientnr AS patient_number,
    Alder AS age,
    Foedselsaar AS birth_year,
    Status AS status,
    Status_kode AS status_code,
    Dato_opprettet AS date_created_business,

    -- Location Info
    Avdeling AS department_name,
    Kommune AS municipality,
    Moetested AS meeting_place,

    -- Flags
    `zz__IsDeleted` AS is_deleted,
    `zz__IsLocked` AS is_locked,

    -- Metadata
    TO_TIMESTAMP(`zz__Creation_Timestamp__lxm`, "yyyy-MM-dd'T'HH:mm:ssXXX") AS created_at,
    `zz__Creation_AccountName__lxt` AS created_by,
    TO_TIMESTAMP(`zz__Modification_Timestamp__lxm`, "yyyy-MM-dd'T'HH:mm:ssXXX") AS modified_at,
    `zz__Modification_AccountName__lxt` AS modified_by,
    `_ingestion_timestamp` AS ingested_at

FROM lh_bronze.nobs.statpasient_detail
WHERE
    zz__IsDeleted != 9
    AND zz__dummy IS NULL

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_time AS
SELECT
    -- Primary Keys
    `__kplt__ID` AS pk_time_stat_id,
    `_kplt_TimeID` AS pk_time_id, -- Specific ID for the time entry

    -- Foreign Keys
    `_kflt_AvdelingID` AS fk_avdeling_id,
    `_kflt_MedarbeiderID` AS fk_medarbeider_id,
    `_kflt_OrdreID` AS fk_ordre_id,
    `_kflt_Sted` AS fk_sted_id,

    -- Order Info
    `_kflt_Ordrenr` AS order_number,
    NomenklaturKode AS nomenclature_code,
    Produksjonsstatus AS production_status,

    -- Employee & Location Names
    Medarbeider_Navn AS employee_name,
    Avdeling AS department_name,
    Sted AS location_name,

    -- Date Dimensions
    Dato AS date,
    Aar AS year,
    Maaned AS month,
    Uke AS week,

    -- Hours / Metrics
    Timer AS hours_total,
    Timer_I AS hours_category_i, -- Likely Indirect/Internal
    Timer_K AS hours_category_k, -- Likely Clinical (Klinisk)
    Timer_N AS hours_category_n,
    Timer_R AS hours_category_r, -- Likely Travel (Reise)

    -- Calculated Fields
    `_kalt_AutTimer` AS calc_auto_hours,
    `_kalt_MedarbeiderType` AS calc_employee_type,
    `_kalt_OrdreType` AS calc_order_type,

    -- Flags
    `zz__IsDeleted` AS is_deleted,

    -- Metadata
    `zz__Creation_Timestamp__lxm` AS created_at,
    `zz__Creation_AccountName__lxt` AS created_by,
    `zz__Modification_Timestamp__lxm` AS modified_at,
    `zz__Modification_AccountName__lxt` AS modified_by,
    `_ingestion_timestamp` AS ingested_at

FROM lh_bronze.nobs.stattime

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.nobs.s_nobs_vedtak AS
SELECT
    -- Primary Key
    `__kplt__ID` AS pk_stat_vedtak_id,

    -- Foreign Keys
    `_kflt_VedtakID` AS fk_vedtak_id,
    `_kflt_OrdreID` AS fk_ordre_id,
    `_kflt_PersonID` AS fk_person_id,
    `_kflt_AvdelingID` AS fk_avdeling_id,

    -- Decision Info
    Pasientnr AS patient_number,
    Nomenklaturkode AS nomenclature_code,
    Status AS status,
    Type AS type,

    -- Dates
    Dato_Vedtaksdato AS date_decision,
    Dato_SendtNAV AS date_sent_nav,

    -- Calculated Fields
    `_kalt_Type` AS calc_type,

    -- Flags
    `zz__IsDeleted` AS is_deleted,

    -- Metadata
    `zz__Creation_Timestamp__lxm` AS created_at,
    `zz__Creation_AccountName__lxt` AS created_by,
    `zz__Modification_Timestamp__lxm` AS modified_at,
    `zz__Modification_AccountName__lxt` AS modified_by,
    `_ingestion_timestamp` AS ingested_at

FROM lh_bronze.nobs.statvedtak

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }
