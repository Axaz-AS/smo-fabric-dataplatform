# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "e34204fd-d37e-4e43-9b13-c1704b1d2a49",
# META       "default_lakehouse_name": "lh_bronze",
# META       "default_lakehouse_workspace_id": "0090292d-63b6-403d-b31a-2ae7358fc623",
# META       "known_lakehouses": [
# META         {
# META           "id": "e34204fd-d37e-4e43-9b13-c1704b1d2a49"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

# Fabric Notebook - Load Datakvalitet API Data to OneLake

# Imports and Configuration
import requests
import json
from notebookutils import mssparkutils

# Configuration
KEYVAULT_URL = "https://kv-smo-dataplatform.vault.azure.net/"
SECRET_NAME = "datakvalitet-api-bearer-token"

BASE_PATH = "abfss://0090292d-63b6-403d-b31a-2ae7358fc623@onelake.dfs.fabric.microsoft.com/e34204fd-d37e-4e43-9b13-c1704b1d2a49/Files/datakvalitet"

ENDPOINTS = {
    # Avvik
    "report_50": "https://sophiesminde.dkhosting.no/api/reports/50",
    # Tiltak
    "report_51": "https://sophiesminde.dkhosting.no/api/reports/51",
    # Utstyr
    "report_53": "https://sophiesminde.dkhosting.no/api/reports/53", # Hovedobjekter
    "report_54": "https://sophiesminde.dkhosting.no/api/reports/54", # Subobjekter
    # Revisjoner
    "report_55": "https://sophiesminde.dkhosting.no/api/reports/55", # Hovedobjekter
    "report_56": "https://sophiesminde.dkhosting.no/api/reports/56", # Subobjekter (eksl funn (vernerunde))
    "report_57": "https://sophiesminde.dkhosting.no/api/reports/57", # Subobjekter (funn (vernerunde))
    # Risiko
    "report_58": "https://sophiesminde.dkhosting.no/api/reports/58", # Hovedobjekter
    "report_59": "https://sophiesminde.dkhosting.no/api/reports/59"  # Subobjekter
}

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Get Bearer Token from Key Vault
bearer_token = mssparkutils.credentials.getSecret(KEYVAULT_URL, SECRET_NAME)

# Fetch and save raw API responses
for endpoint_name, url in ENDPOINTS.items():
    print(f"Fetching {endpoint_name}...")
    
    response = requests.get(url, headers={"Authorization": f"Bearer {bearer_token}"}, timeout=120)
    response.raise_for_status()
    
    output_path = f"{BASE_PATH}/{endpoint_name}/data.json"
    mssparkutils.fs.put(output_path, response.text, overwrite=True)
    
    print(f"  Saved to {output_path}")

print("Done!")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

INVESTIGATE_MULTI_VALUE_COLUMNS = False

if INVESTIGATE_MULTI_VALUE_COLUMNS:
    # Investigation v2: read full JSON via Spark (no size cap)
    from pyspark.sql import functions as F

    def investigate_multivalue(endpoint_name):
        """Read full JSON via Spark and report columns with >1 value in any row."""
        path = f"{BASE_PATH}/{endpoint_name}/data.json"
        df = spark.read.option("multiline", "true").json(path)
        
        # headers from first row
        headers = df.select(F.col("listReport.headingRow")).first()[0]
        
        # collect all rows' dataColumns
        exploded = df.select(F.explode("listReport.dataRows").alias("row")) \
                    .select("row.dataColumns")
        all_rows = exploded.collect()
        
        max_counts = [0] * len(headers)
        samples = [None] * len(headers)
        
        for r in all_rows:
            cols = r["dataColumns"]
            for i, cell in enumerate(cols):
                if i >= len(headers):
                    continue
                n = len(cell) if cell is not None else 0
                if n > max_counts[i]:
                    max_counts[i] = n
                    if n > 1:
                        samples[i] = cell
        
        print(f"\n=== {endpoint_name} ({len(all_rows)} rows, {len(headers)} columns) ===")
        multi_cols = []
        for i, header in enumerate(headers):
            if max_counts[i] > 1:
                multi_cols.append(header)
                sample_preview = str(samples[i])[:120]
                print(f"  MULTI (max={max_counts[i]}): {header!r}")
                print(f"    sample: {sample_preview}")
        
        if not multi_cols:
            print("  (no multi-value columns)")
        
        return endpoint_name, multi_cols

    results = {}
    for endpoint_name in ENDPOINTS.keys():
        try:
            name, multi_cols = investigate_multivalue(endpoint_name)
            results[name] = multi_cols
        except Exception as e:
            print(f"\n=== {endpoint_name} ERROR: {e} ===")
            results[endpoint_name] = None

    print("\n\n=== COPY THIS INTO YOUR CODE ===")
    print("MULTI_VALUE_COLUMNS_BY_REPORT = {")
    for name, cols in results.items():
        print(f"    {name!r}: {cols!r},")
    print("}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Load JSON data to tables

from pyspark.sql import functions as F

MULTI_VALUE_COLUMNS_BY_REPORT = {
    'report_50': ['Leserettighet', 'Melding til', 'Oppfølgning', 'Skade / konsekvens', 'Årsak (MTO)'],
    'report_51': [],
    'report_53': ['Hendelse'],
    'report_54': [],
    'report_55': ['Funn (funn)', 'Funn (Funn2)', 'IR Tiltak', 'Revisjonsplan', 'Sjekkliste', 'Sjekkpunkter'],
    'report_56': ['Funn IL'],
    'report_57': [],
    'report_58': ['Risikomoment', 'Tiltak'],
    'report_59': ['Tiltak IL'],
}

# endpoint -> target table name (under datakvalitet schema)
TABLE_NAMES = {
    'report_50': 'avvik',
    'report_51': 'tiltak',
    'report_53': 'utstyr_hovedobjekter',
    'report_54': 'utstyr_subobjekter',
    'report_55': 'revisjoner_hovedobjekter',
    'report_56': 'revisjoner_subobjekter_eksl_funn',
    'report_57': 'revisjoner_subobjekter_funn',
    'report_58': 'risiko_hovedobjekter',
    'report_59': 'risiko_subobjekter',
}

def sanitize_column_name(header):
    """Make header safe for use as a Spark/Delta column name."""
    return (header
            .replace(" ", "_")
            .replace("/", "_")
            .replace("(", "")
            .replace(")", ""))

def flatten_api_response(df, multi_value_columns):
    """Extract records from API response structure and flatten dataColumns."""
    headers = df.select(F.col("listReport.headingRow")).first()[0]
    
    exploded = df.select(F.explode("listReport.dataRows").alias("row"))
    records = exploded.select("row.dataColumns")
    
    # Detect and deduplicate column names (some reports may have repeats)
    seen = {}
    col_exprs = []
    for i, header in enumerate(headers):
        col_name = sanitize_column_name(header)
        if col_name in seen:
            seen[col_name] += 1
            col_name = f"{col_name}_{seen[col_name]}"
        else:
            seen[col_name] = 0
        
        if header in multi_value_columns:
            col_exprs.append(F.array_join(F.col("dataColumns")[i], "; ").alias(col_name))
        else:
            col_exprs.append(F.col("dataColumns")[i][0].alias(col_name))
    
    return records.select(col_exprs)

spark.sql("CREATE SCHEMA IF NOT EXISTS datakvalitet")

for endpoint_name, table_name in TABLE_NAMES.items():
    print(f"Loading {endpoint_name} -> datakvalitet.{table_name}...")
    
    multi_cols = MULTI_VALUE_COLUMNS_BY_REPORT.get(endpoint_name, [])
    df_raw = spark.read.option("multiline", "true").json(f"{BASE_PATH}/{endpoint_name}/data.json")
    df_flat = flatten_api_response(df_raw, multi_cols)
    
    (df_flat.write
        .mode("overwrite")
        .option("overwriteSchema", "true")
        .saveAsTable(f"datakvalitet.{table_name}"))
    
    print(f"  Saved {df_flat.count()} records")

print("Done!")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Export tables to Excel — one workbook per main object group

import pandas as pd

OUTPUT_PATH = f"{BASE_PATH}/exports"

# Workbook layout: filename -> list of (sheet_name, table_name)
WORKBOOKS = {
    "avvik.xlsx": [
        ("Avvik", "avvik"),
    ],
    "tiltak.xlsx": [
        ("Tiltak", "tiltak"),
    ],
    "utstyr.xlsx": [
        ("Hovedobjekter", "utstyr_hovedobjekter"),
        ("Subobjekter", "utstyr_subobjekter"),
    ],
    "revisjoner.xlsx": [
        ("Hovedobjekter", "revisjoner_hovedobjekter"),
        ("Subobjekter eksl funn", "revisjoner_subobjekter_eksl_funn"),
        ("Subobjekter funn", "revisjoner_subobjekter_funn"),
    ],
    "risiko.xlsx": [
        ("Hovedobjekter", "risiko_hovedobjekter"),
        ("Subobjekter", "risiko_subobjekter"),
    ],
}

for filename, sheets in WORKBOOKS.items():
    local_path = f"/tmp/{filename}"
    print(f"Building {filename}...")
    
    with pd.ExcelWriter(local_path, engine="openpyxl") as writer:
        for sheet_name, table_name in sheets:
            pdf = spark.table(f"datakvalitet.{table_name}").toPandas()
            # Excel sheet names: max 31 chars, no : \ / ? * [ ]
            safe_sheet = sheet_name[:31]
            pdf.to_excel(writer, index=False, sheet_name=safe_sheet)
            print(f"  {safe_sheet}: {len(pdf)} rows")
    
    mssparkutils.fs.cp(f"file://{local_path}", f"{OUTPUT_PATH}/{filename}", recurse=False)
    print(f"  Uploaded to {OUTPUT_PATH}/{filename}")

print("Done!")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
