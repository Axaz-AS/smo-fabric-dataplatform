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

from pyspark.sql import SparkSession
from notebookutils import mssparkutils

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

spark.sql("CREATE SCHEMA IF NOT EXISTS manual_imports")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from notebookutils import mssparkutils
import re

def clean_column_name(name):
    """Sanitize column names for Delta tables"""
    if not name or name.strip() == '':
        return "unnamed_column"
    # Replace invalid characters with underscore
    cleaned = re.sub(r'[ ,;{}()\n\t=:\.]+', '_', name)
    # Remove leading/trailing underscores
    cleaned = cleaned.strip('_')
    # Prefix with underscore if starts with number
    if cleaned and cleaned[0].isdigit():
        cleaned = f"_{cleaned}"
    return cleaned.lower() if cleaned else "unnamed_column"

def rename_columns(df):
    """Rename all columns safely"""
    new_names = []
    seen = {}
    
    for old_name in df.columns:
        new_name = clean_column_name(old_name)
        
        # Handle duplicates
        if new_name in seen:
            seen[new_name] += 1
            new_name = f"{new_name}_{seen[new_name]}"
        else:
            seen[new_name] = 0
        
        new_names.append(new_name)
    
    return df.toDF(*new_names)

# Base path for CSV files
base_path = "abfss://0090292d-63b6-403d-b31a-2ae7358fc623@onelake.dfs.fabric.microsoft.com/e34204fd-d37e-4e43-9b13-c1704b1d2a49/Files/manual_imports/timetracking_excell/"

# List all files in the folder
files = mssparkutils.fs.ls(base_path)
csv_files = [f for f in files if f.name.endswith('.csv')]

for file in csv_files:
    table_name = file.name.replace('.csv', '').lower().replace(' ', '_').replace('-', '_')
    
    # Read as all strings first to avoid inference issues
    df = spark.read.format("csv") \
        .option("header", "true") \
        .option("inferSchema", "false") \
        .load(file.path)
    
    # Rename columns safely using toDF
    df = rename_columns(df)
    
    # Drop unnamed columns
    cols_to_keep = [c for c in df.columns if not c.startswith("unnamed")]
    df = df.select(cols_to_keep)
    
    df.write.mode("overwrite") \
        .saveAsTable(f"manual_imports.{table_name}")
    
    print(f"Loaded {file.name} -> manual_imports_{table_name} ({df.count()} rows)")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
