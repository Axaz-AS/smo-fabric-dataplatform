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

CREATE OR REPLACE TABLE lh_silver.gapvision.s_gapvision_score AS
SELECT
    FirmaID as company_id,
    ResponseID as fk_response_id,
    `Måling` as measurement, 
    Hendelse as event,
    `Målepunkt` as `group`,
    Sortering as sorting,
    Svardato as answer_date,
    `Spørsmål` as question, 
    Tekst as text, 
    Score as score
FROM lh_bronze.gapvision.v111_score;


-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.gapvision.s_gapvision_utsendelse AS
SELECT
    FirmaID as company_id,
    ResponseID as pk_response_id,
    `Måling` as measurement, 
    Hendelse as event,
    `Målepunkt` as `group`,
    Utsendtdato as sendout_date,
    Svardato as answer_date,
    ExternalReference as external_reference,
    Respondentkommentar as respondent_comment
FROM lh_bronze.gapvision.v111_utsendelse;

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }
