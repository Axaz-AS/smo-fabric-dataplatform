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
-- META         }
-- META       ]
-- META     }
-- META   }
-- META }

-- CELL ********************

CREATE SCHEMA IF NOT EXISTS gapvision

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE TABLE IF NOT EXISTS gapvision.V111_Score (
    FirmaID INT NOT NULL,
    ResponseID INT NOT NULL,
    `Måling` STRING NOT NULL,
    Hendelse STRING NOT NULL,
    `Målepunkt` STRING NOT NULL,
    Sortering INT NOT NULL,
    Svardato DATE,
    `Spørsmål` STRING NOT NULL,
    Tekst STRING NOT NULL,
    Score DOUBLE NOT NULL
)

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE TABLE IF NOT EXISTS gapvision.V111_Utsendelse (
    FirmaID INT NOT NULL,
    ResponseID INT NOT NULL,
    `Måling` STRING NOT NULL,
    Hendelse STRING NOT NULL,
    `Målepunkt` STRING NOT NULL,
    Utsendtdato TIMESTAMP NOT NULL,
    Svardato TIMESTAMP,
    ExternalReference STRING,
    Respondentkommentar STRING
)

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }
