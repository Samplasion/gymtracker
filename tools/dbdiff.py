import sqlite3
import sys

welcome = """
===============================
= DBDiff - Database Diff Tool =
===============================

Compare two SQLite databases and find differences in shared tables and columns.
Useful to identify changes in data before and after migrations.
"""

if len(sys.argv) != 3:
    print("Usage: python dbdiff.py <new_database> <old_database>")
    sys.exit(1)

print(welcome)

print("Comparing databases...")

new_database = sys.argv[1]
old_database = sys.argv[2]

# Connect to the new DB and attach the old DB
conn = sqlite3.connect(new_database)
cursor = conn.cursor()
cursor.execute(f"ATTACH DATABASE '{old_database}' AS old_db;")

# Get list of shared tables
cursor.execute("""
    SELECT name FROM main.sqlite_master 
    WHERE type='table' AND name NOT LIKE 'sqlite_%'
    INTERSECT
    SELECT name FROM old_db.sqlite_master 
    WHERE type='table' AND name NOT LIKE 'sqlite_%';
""")
shared_tables = [row[0] for row in cursor.fetchall()]

for table in shared_tables:
  # 1. Find intersecting columns for this table
  cursor.execute(f"PRAGMA main.table_info('{table}')")
  new_cols = {row[1] for row in cursor.fetchall()}

  cursor.execute(f"PRAGMA old_db.table_info('{table}')")
  old_cols = {row[1] for row in cursor.fetchall()}

  common_cols = list(new_cols.intersection(old_cols))
  cols_str = ", ".join(f'"{c}"' for c in common_cols)

  # 2. Find rows in NEW that differ/don't exist in OLD
  diff_query = f"""
        SELECT 'NEW' AS source, {cols_str} FROM main."{table}"
        EXCEPT
        SELECT 'NEW' AS source, {cols_str} FROM old_db."{table}"
        
        UNION ALL
        
        SELECT 'OLD' AS source, {cols_str} FROM old_db."{table}"
        EXCEPT
        SELECT 'OLD' AS source, {cols_str} FROM main."{table}"
    """

  cursor.execute(diff_query)
  diffs = cursor.fetchall()

  if diffs:
    print(f"\n--- Differences in table: {table} ---")
    print(f"Shared columns: {common_cols}")
    for row in diffs:
      print(row)

conn.close()
