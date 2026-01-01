import json
from pathlib import Path
from pipelines.config_loader import load_config
from pipelines.db_connection import get_connection

def run_response_detection():
    config = load_config()
    rt = config["response_timing"]

    default = rt["default"]

    sql_path = Path(__file__).resolve().parents[1] / "sql" / "09_response_detection.sql"

    with open(sql_path, "r", encoding="utf-8") as f:
        sql_template = f.read()

    sql = sql_template.format(
        entry_threshold=default["entry_threshold"],
        confirmation_periods=default["confirmation_periods"],
        exit_threshold=default["exit_threshold"],
        exit_confirmation_periods=default["exit_confirmation_periods"],
        max_response_window_days=default["max_response_window_days"],
        config_snapshot=json.dumps(default)
    )

    conn = get_connection()
    cur = conn.cursor()
    cur.execute(sql)
    conn.commit()
    cur.close()
    conn.close()

    print("✅ Response detection executed successfully")

if __name__ == "__main__":
    run_response_detection()
