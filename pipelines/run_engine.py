import os
from pipelines.db_connection import get_connection
from pipelines.run_shock_detection import run_shock_detection

SQL_FOLDER = os.path.join(os.path.dirname(__file__), "..", "sql")

SQL_FILES = [
    "05_severity_scoring.sql",
    "06_persistence_detection.sql",
    "07_spillover_detection.sql",
]

def run_sql_file(cursor, filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        sql = f.read()
        cursor.execute(sql)

def run_engine():
    print("▶ Running shock detection with config...")
    run_shock_detection()

    conn = get_connection()
    cur = conn.cursor()

    for sql_file in SQL_FILES:
        path = os.path.join(SQL_FOLDER, sql_file)
        print(f"▶ Running {sql_file}...")
        run_sql_file(cur, path)

    conn.commit()
    cur.close()
    conn.close()

    print("✅ Shock engine executed successfully")

if __name__ == "__main__":
    run_engine()
