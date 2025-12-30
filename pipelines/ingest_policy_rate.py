import pandas as pd
from db_connection import get_connection

CSV_PATH = r"C:\Users\Shehroz\Documents\shock-intelligence-main\data_raw\policy_rate_pakistan.csv"

def ingest_policy_rate():
    df = pd.read_csv(CSV_PATH)
    df.columns = [c.lower().strip() for c in df.columns]

    df = df[["date", "value"]]
    df["country"] = "Pakistan"
    df["indicator"] = "POLICY_RATE"
    df["source"] = "SBP"
    df["frequency"] = "Monthly"

    conn = get_connection()
    cur = conn.cursor()

    for _, row in df.iterrows():
        cur.execute(
            """
            INSERT INTO time_series
            (country, indicator, date, value, source, frequency)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING;
            """,
            (
                row["country"],
                row["indicator"],
                row["date"],
                row["value"],
                row["source"],
                row["frequency"]
            )
        )

    conn.commit()
    cur.close()
    conn.close()

    print("✅ Policy rate ingestion completed successfully")

if __name__ == "__main__":
    ingest_policy_rate()