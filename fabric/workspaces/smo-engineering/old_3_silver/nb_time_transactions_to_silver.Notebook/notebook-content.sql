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

CREATE OR REPLACE TABLE lh_silver.time_tracking.cap_time_transactions_mapped AS (
    -- SQL Query to map Capitech Simployer data to Registrerte Timer format
    -- Source table: capitech_time_transactions
    -- Target format: Registrerte Timer with 20 columns

    WITH 
    -- 0. Deduplicate Source Data
    deduplicated_capitech_time_transactions AS (
        SELECT *
        FROM (
            SELECT *, 
                ROW_NUMBER() OVER (
                    PARTITION BY uid, timeCategory
                    ORDER BY lastUpdatedOn DESC
                ) as rn
            FROM lh_bronze.capitech.time_transactions
        )
        WHERE rn = 1
        AND timeCategoryType != 'Tillegg'
        AND NOT isDeleted
    ),
    -- 1. Deduplicate mapping of (employee name <--> employee) department in case multiple exist
    dim_employee_department AS (
        SELECT 
            ansatt, 
            avd, 
            avd2
        FROM (
            SELECT *, 
                ROW_NUMBER() OVER (
                    PARTITION BY ansatt 
                    ORDER BY avd DESC -- Consistently picks one department
                ) as rn
            FROM lh_bronze.excel_mappings.ansatt_avdeling
        ) 
        WHERE rn = 1
    ),
    -- 2. Ensure 1 row per time category
    dim_time_categories AS (
        SELECT tidskategori, kategori1, kategori2
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY tidskategori ORDER BY (SELECT NULL)) as rn
            FROM lh_bronze.excel_mappings.tidskategori
        )
        WHERE rn = 1
    )

    SELECT
        -- 1. date - Date from dateIn and transform leap year day to Feb 28th
        CASE 
            WHEN t.dateIn LIKE '%-02-29' THEN TO_DATE(REPLACE(t.dateIn, '-02-29', '-02-28'), 'yyyy-MM-dd')
            ELSE TO_DATE(t.dateIn, 'yyyy-MM-dd')
        END AS transaction_date,

        -- 2-8. NOBS-specific columns (always NULL for Simployer data)
        CAST(NULL AS STRING) AS order_type,
        CAST(NULL AS STRING) AS order_number,
        CAST(NULL AS STRING) AS employee_type,
        CAST(NULL AS STRING) AS employee_id,
        CAST(NULL AS STRING) AS employee_name,
        CAST(NULL AS STRING) AS nomenclature_code,
        CAST(NULL AS STRING) AS production_status,

        -- 9. hours - Hours worked
        t.qty AS hours,

        -- 10. department_full - Full department name
        dep.avd AS department_full,

        -- 11. department_location - Location extracted from department name
        dep.avd2 AS department_location,

        -- 12-15. More NOBS-specific columns (always NULL for Simployer data)
        CAST(NULL AS STRING) AS fixed_price_codes,
        CAST(NULL AS STRING) AS product_groups,
        CAST(NULL AS STRING) AS nomenclature_text,
        CAST(NULL AS STRING) AS specialty_area,

        -- 16. employee_simployer - Employee name from Simployer
        t.employee AS employee_simployer,

        -- 17. source - Always 'Simployer' for Capitech data
        'Simployer' AS source,

        -- 18. time_category - Time category from source
        t.timeCategory AS time_category,

        -- 19. category_main - Main category classification
        a.kategori1 AS category_main,

        -- 20. category_detail - Detailed category classification
        a.kategori2 AS category_detail

    FROM deduplicated_capitech_time_transactions t
    LEFT JOIN dim_employee_department dep
        ON t.employee = dep.ansatt
    LEFT JOIN dim_time_categories a
        ON t.timeCategory = a.tidskategori
)

    -- WHERE isDeleted = FALSE
    --  AND qty > 0

    --ORDER BY employee_simployer, transaction_date, hours DESC

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.time_tracking.cap_absence_transactions_mapped AS (
    -- SQL Query to map Capitech Absence data to Registrerte Timer format
    -- Source table: absence_transactions
    -- Target format: Registrerte Timer with 20 columns

    WITH 
    -- 0. Deduplicate Source Data using updatedOn
    deduplicated_absence AS (
        SELECT *
        FROM (
            SELECT *, 
                ROW_NUMBER() OVER (
                    PARTITION BY 
                        absenceId,
                        dayDate
                    ORDER BY updatedOn DESC
                ) as rn
            FROM lh_bronze.capitech.absence_transactions
        )
        WHERE rn = 1
        AND NOT isDeleted
    ),
    -- 1. Deduplicate mapping of employee department
    dim_employee_department AS (
        SELECT 
            ansatt, 
            avd, 
            avd2
        FROM (
            SELECT *, 
                ROW_NUMBER() OVER (
                    PARTITION BY ansatt 
                    ORDER BY avd DESC -- Consistently picks one department
                ) as rn
            FROM lh_bronze.excel_mappings.ansatt_avdeling
        ) 
        WHERE rn = 1
    ),
    -- 2. Deduplicate category mapping
    dim_time_categories AS (
        SELECT tidskategori, kategori1, kategori2
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY tidskategori ORDER BY (SELECT NULL)) as rn
            FROM lh_bronze.excel_mappings.tidskategori
        )
        WHERE rn = 1
    )

    SELECT
        -- 1. date - Date from dayDate (the actual day of absence) and transform leap year day to Feb 28th
        CASE 
            WHEN ab.dayDate LIKE '%-02-29' THEN TO_DATE(REPLACE(ab.dayDate, '-02-29', '-02-28'), 'yyyy-MM-dd')
            ELSE TO_DATE(ab.dayDate, 'yyyy-MM-dd')
        END AS transaction_date,

        -- 2-8. NOBS-specific columns (always NULL for Simployer data)
        CAST(NULL AS STRING) AS order_type,
        CAST(NULL AS STRING) AS order_number,
        CAST(NULL AS STRING) AS employee_type,
        CAST(NULL AS STRING) AS employee_id,
        CAST(NULL AS STRING) AS employee_name,
        CAST(NULL AS STRING) AS nomenclature_code,
        CAST(NULL AS STRING) AS production_status,

        -- 9. hours - Hours from dayCalculatedHours
        dayCalculatedHours AS hours,

        -- 10. department_full - Full department name
        dep.avd AS department_full,

        -- 11. department_location - Location extracted from department name
        dep.avd2 AS department_location,

        -- 12-15. More NOBS-specific columns (always NULL for Simployer data)
        CAST(NULL AS STRING) AS fixed_price_codes,
        CAST(NULL AS STRING) AS product_groups,
        CAST(NULL AS STRING) AS nomenclature_text,
        CAST(NULL AS STRING) AS specialty_area,

        -- 16. employee_simployer - Employee name from Simployer
        employee AS employee_simployer,

        -- 17. source - Always 'Simployer' for Capitech data
        'Simployer' AS source,

        -- 18. time_category - Use absenceDescription as it's more descriptive
        ab.absenceDescription AS time_category,

        -- 19. category_main - Main category classification
        a.kategori1 AS category_main,

        -- 20. category_detail - Detailed category classification
        a.kategori2 AS category_detail

    FROM deduplicated_absence ab
    LEFT JOIN dim_employee_department dep
    ON ab.employee = dep.ansatt
    LEFT JOIN dim_time_categories a
    ON ab.absenceDescription = a.tidskategori

    -- WHERE isDeleted = FALSE
    --   AND dayCalculatedHours > 0

    --ORDER BY ab.dayDate, ab.employeeId, ab.absenceId
    --ORDER BY employee_simployer, transaction_date, hours DESC
)

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.time_tracking.nobs_stattime_mapped AS (
    WITH 
    -- 0. Step 1: Strict Deduplication First, filter invalid order numbers
    deduplicated_source AS (
        SELECT *
        FROM (
            SELECT *, 
                ROW_NUMBER() OVER (
                    PARTITION BY __kplt__ID 
                    ORDER BY _ingestion_timestamp DESC
                ) as rn
            FROM lh_bronze.nobs.stattime
            WHERE _kflt_Ordrenr IS NOT NULL 
              AND _kflt_Ordrenr != '1'
        ) 
        WHERE rn = 1
    ),

    -- 0. Step 2: "Fill Upwards" on Clean Data, partitioned per order number
    normalized_stattime AS (
        SELECT 
            *,
            COALESCE(
                Dato, 
                FIRST_VALUE(Dato, true) OVER (
                    PARTITION BY _kflt_Ordrenr
                    ORDER BY _kflt_Ordrenr ASC
                    ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                )
            ) AS normalized_dato
        FROM deduplicated_source
    ),

    -- 1. Deduplicate Nomenclature Mapping
    dim_nomenklatur AS (
        SELECT * 
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY nomenklatur_kode ORDER BY (SELECT NULL)) as rn
            FROM lh_bronze.excel_mappings.nomenklatur
        ) 
        WHERE rn = 1
    ),

    -- 2. Deduplicate NOBS-to-Simployer Name Mapping
    dim_ark2 AS (
        SELECT * 
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY `navn nobs` ORDER BY (SELECT NULL)) as rn
            FROM lh_bronze.excel_mappings.ansatt_navn
        ) 
        WHERE rn = 1
    ),

    -- 3. Deduplicate Employee Department Data
    dim_employee_department AS (
        SELECT 
            ansatt, 
            avd, 
            avd2
        FROM (
            SELECT *, 
                ROW_NUMBER() OVER (
                    PARTITION BY ansatt 
                    ORDER BY avd DESC
                ) as rn
            FROM lh_bronze.excel_mappings.ansatt_avdeling
        ) 
        WHERE rn = 1
    )

    SELECT
        -- 1. Date - transform leap year day to Feb 28th
        CASE 
            WHEN t.normalized_dato LIKE '%-02-29' THEN TO_DATE(REPLACE(t.normalized_dato, '-02-29', '-02-28'), 'yyyy-MM-dd')
            ELSE TO_DATE(t.normalized_dato, 'yyyy-MM-dd')
        END AS transaction_date,

        -- 2-8. NOBS-specific columns
        t._kalt_OrdreType AS order_type,
        t._kflt_Ordrenr AS order_number,
        t._kalt_MedarbeiderType AS employee_type,
        COALESCE(t._kflt_MedarbeiderID, 'Overstyrt timer') AS employee_id,
        COALESCE(t.Medarbeider_Navn, 'Overstyrt timer') AS employee_name,
        t.NomenklaturKode AS nomenclature_code,
        t.Produksjonsstatus AS production_status,

        -- 9. Hours worked
        t.Timer AS hours,

        -- 10. Full department name
        COALESCE(dep.avd, 'Overstyrt timer') AS department_full,

        -- 11. Department location
        COALESCE(dep.avd2, 'Overstyrt timer') AS department_location,

        -- 12-15. Nomenclature enrichment
        n.fastpris AS fixed_price_codes,
        n.produktgrupper AS product_groups,
        n.`beskrivelse n` AS nomenclature_text,
        n.`fagområde` AS specialty_area,

        -- 16. Simployer employee name
        COALESCE(a.`navn simployer`, 'Overstyrt timer') AS employee_simployer,

        -- 17. Source identifier
        'NOBS' AS source,

        -- 18-20. Category columns
        CAST(NULL AS STRING) AS time_category,
        CAST("NOBS" AS STRING) AS category_main,
        CAST(NULL AS STRING) AS category_detail

    FROM normalized_stattime AS t
    LEFT JOIN dim_nomenklatur AS n
        ON t.NomenklaturKode = n.nomenklatur_kode
    LEFT JOIN dim_ark2 AS a
        ON t.Medarbeider_Navn = a.`navn nobs`
    LEFT JOIN dim_employee_department AS dep
        ON a.`navn simployer` = dep.ansatt
)

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE SCHEMA IF NOT EXISTS lh_silver.time_tracking

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE OR REPLACE TABLE lh_silver.time_tracking.unified_time_transactions AS (
    -- Unified time transactions from all sources
    -- Sources: NOBS StatTime, Capitech Time Transactions, Capitech Absence Transactions
    
    -- NOBS Production Time
    SELECT*
    FROM lh_silver.time_tracking.nobs_stattime_mapped

    UNION ALL

    -- Capitech Time Transactions (Simployer)
    SELECT *
    FROM lh_silver.time_tracking.cap_time_transactions_mapped

    UNION ALL

    -- Capitech Absence Transactions (Simployer)
    SELECT *
    FROM lh_silver.time_tracking.cap_absence_transactions_mapped
)

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

WITH silver_summary AS (
    SELECT 
        transaction_date, 
        source, 
        ROUND(SUM(hours), 2) as silver_hours
    FROM lh_silver.time_tracking.unified_time_transactions
    GROUP BY 1, 2
),
excel_summary AS (
    SELECT 
        dato, 
        kilde, 
        ROUND(SUM(CAST(timer AS DOUBLE)), 2) as excel_hours
    FROM lh_bronze.manual_imports.registrerte_timer
    GROUP BY 1, 2
)
SELECT 
    COALESCE(s.transaction_date, e.dato) as date,
    COALESCE(s.source, e.kilde) as source,
    s.silver_hours,
    e.excel_hours,
    (s.silver_hours - e.excel_hours) as variance,
    CASE 
        WHEN e.excel_hours IS NULL OR e.excel_hours = 0 THEN 100.0 
        ELSE ROUND(((s.silver_hours - e.excel_hours) / e.excel_hours) * 100, 2)
    END AS pct_diff
FROM silver_summary s
FULL OUTER JOIN excel_summary e 
    ON s.transaction_date = e.dato AND s.source = e.kilde
WHERE ABS(s.silver_hours - e.excel_hours) > 0.01
order by ABS(pct_diff) desc, ABS(variance) desc

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- MARKDOWN ********************

-- ### By Month

-- CELL ********************

WITH silver_summary AS (
    SELECT 
        DATE_TRUNC('month', transaction_date) AS month,
        source, 
        ROUND(SUM(hours), 2) AS silver_hours
    FROM lh_silver.time_tracking.unified_time_transactions
    GROUP BY 1, 2
),
excel_summary AS (
    SELECT 
        DATE_TRUNC('month', dato) AS month,
        kilde, 
        ROUND(SUM(CAST(timer AS DOUBLE)), 2) AS excel_hours
    FROM lh_bronze.manual_imports.registrerte_timer
    GROUP BY 1, 2
)
SELECT 
    COALESCE(s.month, e.month) AS month,
    COALESCE(s.source, e.kilde) AS source,
    s.silver_hours,
    e.excel_hours,
    (s.silver_hours - e.excel_hours) AS variance,
    CASE 
        WHEN e.excel_hours IS NULL OR e.excel_hours = 0 THEN 100.0 
        ELSE ROUND(((s.silver_hours - e.excel_hours) / e.excel_hours) * 100, 2)
    END AS pct_diff
FROM silver_summary s
FULL OUTER JOIN excel_summary e 
    ON s.month = e.month AND s.source = e.kilde
WHERE ABS(s.silver_hours - e.excel_hours) > 0.01
ORDER BY month DESC, ABS(pct_diff) DESC, ABS(variance) DESC

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }
