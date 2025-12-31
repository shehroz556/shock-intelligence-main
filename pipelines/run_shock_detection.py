from pathlib import Path
from pipelines.config_loader import load_config
from pipelines.db_connection import get_connection

def run_shock_detection():
    config = load_config()

    rolling_window = config["shock_detection"]["rolling_window_periods"]
    z_threshold = config["shock_detection"]["z_score_threshold"]

    sql_path = Path(__file__).resolve().parents[1] / "sql" / "04_shock_detection.sql"

    with open(sql_path, "r", encoding="utf-8") as f:
        sql_template = f.read()

    sql = sql_template.format(
        rolling_window=rolling_window,
        z_threshold=z_threshold
    )

    conn = get_connection()
    cur = conn.cursor()
    cur.execute(sql)
    conn.commit()
    cur.close()
    conn.close()

    print("✅ Shock detection executed using config parameters")

if __name__ == "__main__":
    run_shock_detection()
