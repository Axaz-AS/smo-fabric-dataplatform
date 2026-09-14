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

from pyspark.sql.functions import explode, col

# Define source file paths
files = {
    "time_transactions": "abfss://0090292d-63b6-403d-b31a-2ae7358fc623@onelake.dfs.fabric.microsoft.com/e34204fd-d37e-4e43-9b13-c1704b1d2a49/Files/capitech/getTimeTransactions/*.json",
    "absence_transactions": "abfss://0090292d-63b6-403d-b31a-2ae7358fc623@onelake.dfs.fabric.microsoft.com/e34204fd-d37e-4e43-9b13-c1704b1d2a49/Files/capitech/getAbsenceTransactions/*.json"
}

# Create schema if it doesn't exist
spark.sql("CREATE SCHEMA IF NOT EXISTS capitech")

def load_json_to_delta(file_path: str, table_name: str) -> None:
    df_raw = spark.read.option("multiline", "false").json(file_path)
    df = df_raw.select(explode(col("content")).alias("record")).select("record.*")
    df.write.mode("overwrite").option("overwriteSchema", "true").format("delta").saveAsTable(table_name)
    print(f"Loaded {df.count()} records into {table_name}")

# Load both files
load_json_to_delta(files["time_transactions"], "capitech.time_transactions")
load_json_to_delta(files["absence_transactions"], "capitech.absence_transactions")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
