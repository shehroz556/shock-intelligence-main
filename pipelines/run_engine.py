import os
from pipelines.db_connection import get_connection
from pipelines.run_shock_detection import run_shock_detection
from pipelines.run_spillover_detection import run_spillover_detection
from pipelines.run_response_detection import run_response_detection

BASE_DIR = os.path.dirname(__file__)
SQL_FOLDER = os.path.join(BASE_DIR, "..", "sql")

# ───────── SCHEMA FILES (CREATE / ALTER ONLY) ─────────
SCHEMA_FILES = [
    "00_schema_setup.sql",
    "08_response_events_schema.sql",
    "11_system_stress_index_schema.sql",
]

# ───────── ANALYTICAL SQL FILES ─────────
LOGIC_FILES = [
    "05_severity_scoring.sql",
    "06_persistence_detection.sql",
    "10_shock_normalization.sql",
    "11_system_stress_index.sql",
    "13_stress_regime_classification.sql",
    "06_powerbi_views.sql",
]

def run_sql_file(cursor, filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        sql = f.read()
        cursor.execute(sql)

def ensure_base_columns(cursor):
    """
    Absolute guarantees for columns required by downstream logic.
    Makes pipeline idempotent after hard resets.
    """
    cursor.execute("""
        ALTER TABLE shock_events
        ADD COLUMN IF NOT EXISTS severity_percentile NUMERIC;
    """)

    cursor.execute("""
        ALTER TABLE shock_events
        ADD COLUMN IF NOT EXISTS persistence_periods INTEGER;
    """)

def run_engine():
    # 1️⃣ Shock detection (Python-driven, creates rows in shock_events)
    print("▶ Running shock detection with config...")
    run_shock_detection()

    conn = get_connection()
    cur = conn.cursor()

    # 2️⃣ Ensure critical columns exist
    print("▶ Ensuring base schema columns...")
    ensure_base_columns(cur)
    conn.commit()

    # 3️⃣ Run schema files
    print("▶ Running schema setup files...")
    for sql_file in SCHEMA_FILES:
        path = os.path.join(SQL_FOLDER, sql_file)
        print(f"▶ Running {sql_file}...")
        run_sql_file(cur, path)
        conn.commit()

    # 4️⃣ Run analytical SQL logic
    print("▶ Running analytical SQL files...")
    for sql_file in LOGIC_FILES:
        path = os.path.join(SQL_FOLDER, sql_file)
        print(f"▶ Running {sql_file}...")
        run_sql_file(cur, path)
        conn.commit()

    cur.close()
    conn.close()

    # 5️⃣ Transmission & response layers
    print("▶ Running spillover detection with config...")
    run_spillover_detection()

    print("▶ Running response detection with config...")
    run_response_detection()

    print("✅ Shock intelligence engine executed successfully")

if __name__ == "__main__":
    run_engine()
