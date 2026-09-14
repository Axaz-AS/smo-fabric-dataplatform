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

# MARKDOWN ********************

# Fabric Notebook: NOBS JSON to Delta Lake Ingestion
# ===================================================
# This notebook reads JSON files from the lakehouse Files area
# and writes them to Delta tables in the nobs schema.

# MARKDOWN ********************

# ## Configuration

# CELL ********************

# List of entities to process
ENTITIES = [
    "STAT_Statistikk",
    "StatEvent",
    "StatKliniker",
    "StatNomenklatur_detail",
    "StatOrdrehistorikk",
    "StatOrdrelinje",
    "StatPasient_detail",
    "StatTime",
    "StatVedtak",
]

# Entities to skip
SKIP_ENTITIES = []

# Schema name for target tables
TARGET_SCHEMA = "nobs"

# Base path for source files (in lakehouse Files area)
BASE_PATH = "Files/nobs"

# Load mode: "full" or "incremental"
LOAD_MODE = "full"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Helper Functions

# CELL ********************

from pyspark.sql import DataFrame
from pyspark.sql.functions import explode, col, lit, current_timestamp
from pyspark.sql.utils import AnalysisException


def get_latest_source_path(entity: str, mode: str = "full") -> str:
    """
    Returns the path of the newest JSON file for the given entity and load mode.
    
    For full load: scans nobs/{entity}/*/*.json and returns the most recently
    modified file based on file metadata.
    """
    if mode == "full":
        search_path = f"{BASE_PATH}/{entity}"
        
        # List all JSON files recursively under the entity folder
        all_files = mssparkutils.fs.ls(search_path)
        
        # Recursively collect all .json files with their modification time
        json_files = []
        for folder in all_files:
            if folder.isDir:
                try:
                    sub_files = mssparkutils.fs.ls(folder.path)
                    json_files.extend(
                        f for f in sub_files if f.name.endswith(".json")
                    )
                except Exception:
                    pass
            elif folder.name.endswith(".json"):
                json_files.append(folder)
        
        if not json_files:
            raise FileNotFoundError(f"No JSON files found for entity '{entity}' at {search_path}")
        
        # Pick the file with the latest modification time
        newest_file = max(json_files, key=lambda f: f.modifyTime)
        print(f"  🕒 Newest file: {newest_file.path} (modified: {newest_file.modifyTime})")
        
        return newest_file.path
    else:
        raise NotImplementedError("Incremental load mode is not yet supported.")


def get_source_path(entity: str, mode: str = "full") -> str:
    """
    Construct the source file path based on entity and load mode.
    
    For full load: nobs/{entity}/full.json
    For incremental: nobs/{entity}/incremental/{load_date}/{run_id}.json
    """
    if mode == "full":
        return f"{BASE_PATH}/{entity}/*/*.json"
    else:
        # For incremental, we'd need to handle date/run_id selection
        # This will be expanded when incremental loading is implemented
        return f"{BASE_PATH}/{entity}/incremental/*/*.json"


def read_json_with_inference(spark, path: str) -> DataFrame:
    """
    Read JSON file(s) with schema inference.
    Handles the OData wrapper structure by extracting the 'value' array.
    """
    # Read the raw JSON with schema inference
    #raw_df = spark.read.option("multiLine", "false").json(path)

    raw_df = (
        spark.read
        .option("multiLine", "false")
        .option("mode", "PERMISSIVE")
        .option("prefersDecimal", "false")
        .option("primitivesAsString", "false")
        .json(path)
    )
    
    # The actual data is nested in the 'value' array (OData format)
    # Explode it to get individual records
    if "value" in raw_df.columns:
        df = raw_df.select(explode(col("value")).alias("data")).select("data.*")
    else:
        # If no 'value' column, assume flat structure
        df = raw_df
    
    return df


def clean_column_names(df: DataFrame) -> DataFrame:
    """
    Clean column names by removing special characters that may cause issues.
    Replaces @ with empty string and other problematic chars with underscore.
    """
    new_columns = []
    for col_name in df.columns:
        new_name = col_name.replace("@", "").replace(".", "_")
        new_columns.append(new_name)
    
    return df.toDF(*new_columns)


def entity_to_table_name(entity: str) -> str:
    """
    Convert entity name to a clean table name.
    Converts to lowercase and handles any special characters.
    """
    return entity.lower().replace("-", "_")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Create Target Schema

# CELL ********************

spark.sql(f"CREATE SCHEMA IF NOT EXISTS {TARGET_SCHEMA}")
print(f"Schema '{TARGET_SCHEMA}' is ready.")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Main Processing Loop

# CELL ********************

results = []

for entity in ENTITIES:
    print(f"\n{'='*60}")
    print(f"Processing entity: {entity}")
    print(f"{'='*60}")
    
    if entity in SKIP_ENTITIES:
        print(f"  ⏭️  Skipping {entity} (no data available)")
        results.append({"entity": entity, "status": "skipped", "rows": 0})
        continue
    
    try:
        # Get the newest source file path
        source_path = get_latest_source_path(entity, LOAD_MODE)
        print(f"  📂 Source: {source_path}")
        
        df = read_json_with_inference(spark, source_path)
        df = clean_column_names(df)
        df = df.withColumn("_ingestion_timestamp", current_timestamp())
        
        row_count = df.count()
        print(f"  📊 Rows read: {row_count}")
        
        table_name = entity_to_table_name(entity)
        full_table_name = f"{TARGET_SCHEMA}.{table_name}"
        
        df.write \
            .format("delta") \
            .mode("overwrite") \
            .option("overwriteSchema", "true") \
            .saveAsTable(full_table_name)
        print(f"  ✅ Written to: {full_table_name}")
        results.append({"entity": entity, "status": "success", "rows": row_count})
        
    except FileNotFoundError as e:
        print(f"  ⚠️  File not found for {entity}: {e}")
        results.append({"entity": entity, "status": "file_not_found", "rows": 0})
    except AnalysisException as e:
        print(f"  ❌ Analysis error: {str(e)}")
        results.append({"entity": entity, "status": "error", "rows": 0, "error": str(e)})
    except Exception as e:
        print(f"  ❌ Error: {str(e)}")
        results.append({"entity": entity, "status": "error", "rows": 0, "error": str(e)})

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Summary Report

# CELL ********************

print("\n" + "="*60)
print("INGESTION SUMMARY")
print("="*60)

# Convert results to DataFrame for nice display
results_df = spark.createDataFrame(results)
display(results_df)

# Print totals
success_count = sum(1 for r in results if r["status"] == "success")
total_rows = sum(r["rows"] for r in results)

print(f"\nEntities processed successfully: {success_count}/{len(ENTITIES)}")
print(f"Total rows ingested: {total_rows:,}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
