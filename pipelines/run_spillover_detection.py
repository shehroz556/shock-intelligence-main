from pathlib import Path
from pipelines.config_loader import load_config
from pipelines.db_connection import get_connection

def run_spillover_detection():
    config = load_config()

    reaction_window_days = config["spillover_detection"]["reaction_window_days"]
    min_avg_deviation = config["spillover_detection"]["min_avg_deviation"]
    min_max_deviation = config["spillover_detection"]["min_max_deviation"]

    sql_path = Path(__file__).resolve().parents[1] / "sql" / "07_spillover_detection.sql"

    with open(sql_path, "r", encoding="utf-8") as f:
        sql_template = f.read()

    sql = sql_template.format(
        reaction_window_days=reaction_window_days,
        min_avg_deviation=min_avg_deviation,
        min_max_deviation=min_max_deviation
    )

    conn = get_connection()
    cur = conn.cursor()
    cur.execute(sql)
    conn.commit()
    cur.close()
    conn.close()

    print("✅ Spillover detection executed using config parameters")

if __name__ == "__main__":
    run_spillover_detection()
