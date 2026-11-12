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

# Fabric Notebook: NOBS JSON to Delta Lake Ingestion (Resilient)
# ==============================================================
# This notebook reads the raw OData export written by the ADF download path
# (`Files/nobs/{entity}/{load_date}/raw_page.json`) and writes it to Delta
# tables in the nobs schema.
#
# Unlike `nb_nobs_load_json`, this notebook does NOT use `spark.read.json`.
# It reads the raw bytes, decodes them permissively, and parses the
# concatenated OData pages with a streaming JSON decoder. Records that
# contain invalid UTF-8 bytes are quarantined at record level instead of
# failing the whole load.

# MARKDOWN ********************

# ## Configuration

# CELL ********************

# Entities produced by the raw download path
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

# Schema name for target tables
TARGET_SCHEMA = "nobs"

# Base path for source files (in lakehouse Files area)
BASE_PATH = "Files/nobs"

# Name of the raw export file inside each load_date folder
RAW_FILE_NAME = "raw_page.json"

# Quarantine table for records that could not be loaded
QUARANTINE_TABLE = f"{TARGET_SCHEMA}._quarantine"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Helper Functions

# CELL ********************

import json

from pyspark.sql import DataFrame
from pyspark.sql.functions import col, current_timestamp
from pyspark.sql.types import (
    LongType,
    StringType,
    StructField,
    StructType,
    TimestampType,
)
from pyspark.sql.utils import AnalysisException


def get_latest_load_date(entity: str) -> str:
    """
    Return the latest load_date subfolder name for the given entity.

    Each subfolder of Files/nobs/{entity}/ is a load_date (e.g. 2026-11-11).
    """
    entity_path = f"{BASE_PATH}/{entity}"
    folders = mssparkutils.fs.ls(entity_path)
    load_dates = sorted(f.name for f in folders if f.isDir)
    if not load_dates:
        raise FileNotFoundError(f"No load_date folders found for entity '{entity}' at {entity_path}")
    return load_dates[-1]


def get_raw_file_path(entity: str, load_date: str) -> str:
    """Return the path of the raw export file for an entity and load_date."""
    return f"{BASE_PATH}/{entity}/{load_date}/{RAW_FILE_NAME}"


def read_raw_bytes(path: str) -> bytes:
    """Read the raw export file as bytes (no JSON parsing, no decoding)."""
    row = spark.read.binaryFile(path).select("data").first()
    if row is None:
        raise FileNotFoundError(f"Raw file is empty or unreadable: {path}")
    return bytes(row["data"])


def parse_raw_pages(raw_bytes: bytes, entity: str, load_date: str):
    """
    Parse the concatenated OData page responses in raw_bytes.

    Returns (good_records, quarantined):
      - good_records: list of record dicts that decoded cleanly
      - quarantined:  list of quarantine dicts for records/pages that did not

    The file is N adjacent JSON objects (one per OData page). Bad bytes are
    replaced with U+FFFD during decode; any record whose serialized form
    contains U+FFFD is quarantined instead of loaded.
    """
    good_records = []
    quarantined = []

    text = raw_bytes.decode("utf-8", errors="replace")
    decoder = json.JSONDecoder()
    idx = 0
    page_index = 0

    while idx < len(text):
        # Skip whitespace between adjacent page objects
        while idx < len(text) and text[idx].isspace():
            idx += 1
        if idx >= len(text):
            break

        try:
            page, end = decoder.raw_decode(text, idx)
        except json.JSONDecodeError as e:
            # Guard: quarantine the remainder of the stream and stop
            quarantined.append({
                "entity": entity,
                "load_date": load_date,
                "page_index": page_index,
                "record_index": -1,
                "raw_record": text[idx:idx + 2000],
                "error": f"page JSON parse failed: {e}",
            })
            break

        page_text = text[idx:end]
        idx = end

        if not isinstance(page, dict):
            quarantined.append({
                "entity": entity,
                "load_date": load_date,
                "page_index": page_index,
                "record_index": -1,
                "raw_record": page_text[:2000],
                "error": "page is not a JSON object",
            })
            page_index += 1
            continue

        for record_index, record in enumerate(page.get("value", [])):
            serialized = json.dumps(record, ensure_ascii=False)
            if "\ufffd" in serialized:
                quarantined.append({
                    "entity": entity,
                    "load_date": load_date,
                    "page_index": page_index,
                    "record_index": record_index,
                    "raw_record": serialized,
                    "error": "invalid UTF-8 byte (U+FFFD) detected",
                })
            else:
                good_records.append(record)

        page_index += 1

    return good_records, quarantined


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


QUARANTINE_SCHEMA = StructType([
    StructField("entity", StringType(), False),
    StructField("load_date", StringType(), False),
    StructField("page_index", LongType(), False),
    StructField("record_index", LongType(), False),
    StructField("raw_record", StringType(), True),
    StructField("error", StringType(), True),
    StructField("ingested_at", TimestampType(), False),
])

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
all_quarantined = []

for entity in ENTITIES:
    print(f"\n{'='*60}")
    print(f"Processing entity: {entity}")
    print(f"{'='*60}")

    try:
        load_date = get_latest_load_date(entity)
        source_path = get_raw_file_path(entity, load_date)
        print(f"  📂 Source: {source_path} (load_date: {load_date})")

        raw_bytes = read_raw_bytes(source_path)
        print(f"  📊 Raw bytes read: {len(raw_bytes):,}")

        good_records, quarantined = parse_raw_pages(raw_bytes, entity, load_date)
        print(f"  📊 Records parsed: {len(good_records):,} good, {len(quarantined):,} quarantined")

        all_quarantined.extend(quarantined)

        if not good_records:
            print(f"  ⚠️  No good records for {entity}; skipping write.")
            results.append({
                "entity": entity,
                "load_date": load_date,
                "status": "no_good_records",
                "rows": 0,
                "quarantined": len(quarantined),
            })
            continue

        df = spark.createDataFrame(good_records)
        df = clean_column_names(df)
        df = df.withColumn("_ingestion_timestamp", current_timestamp())

        row_count = df.count()
        table_name = entity_to_table_name(entity)
        full_table_name = f"{TARGET_SCHEMA}.{table_name}"

        df.write \
            .format("delta") \
            .mode("overwrite") \
            .option("overwriteSchema", "true") \
            .saveAsTable(full_table_name)
        print(f"  ✅ Written to: {full_table_name}")
        results.append({
            "entity": entity,
            "load_date": load_date,
            "status": "success",
            "rows": row_count,
            "quarantined": len(quarantined),
        })

    except FileNotFoundError as e:
        print(f"  ⚠️  File not found for {entity}: {e}")
        results.append({
            "entity": entity,
            "load_date": None,
            "status": "file_not_found",
            "rows": 0,
            "quarantined": 0,
        })
    except AnalysisException as e:
        print(f"  ❌ Analysis error: {str(e)}")
        results.append({
            "entity": entity,
            "load_date": None,
            "status": "error",
            "rows": 0,
            "quarantined": 0,
            "error": str(e),
        })
    except Exception as e:
        print(f"  ❌ Error: {str(e)}")
        results.append({
            "entity": entity,
            "load_date": None,
            "status": "error",
            "rows": 0,
            "quarantined": 0,
            "error": str(e),
        })

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Quarantine

# CELL ********************

if all_quarantined:
    print("\n" + "="*60)
    print("QUARANTINED RECORDS")
    print("="*60)

    for q in all_quarantined:
        print(
            f"🚨 QUARANTINED {q['entity']} page={q['page_index']} "
            f"record={q['record_index']}: {q['error']}"
        )
        print(f"   raw_record: {q['raw_record'][:200]}")

    quarantine_rows = [
        (
            q["entity"],
            q["load_date"],
            q["page_index"],
            q["record_index"],
            q["raw_record"],
            q["error"],
        )
        for q in all_quarantined
    ]
    quarantine_df = spark.createDataFrame(quarantine_rows, schema=QUARANTINE_SCHEMA[:-1])
    quarantine_df = quarantine_df.withColumn("ingested_at", current_timestamp())

    quarantine_df.write \
        .format("delta") \
        .mode("append") \
        .option("mergeSchema", "true") \
        .saveAsTable(QUARANTINE_TABLE)
    print(f"\n✅ Appended {len(quarantine_rows):,} quarantined records to {QUARANTINE_TABLE}")
else:
    print("\n✅ No quarantined records.")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Summary

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
total_quarantined = sum(r["quarantined"] for r in results)

print(f"\nEntities processed successfully: {success_count}/{len(ENTITIES)}")
print(f"Total rows ingested: {total_rows:,}")
print(f"Total records quarantined: {total_quarantined:,}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
