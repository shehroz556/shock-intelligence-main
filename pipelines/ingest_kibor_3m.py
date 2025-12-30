import pandas as pd
from db_connection import get_connection

CSV_PATH = r"C:\Users\Shehroz\Documents\shock-intelligence-main\data_raw\kibor_3m_daily.csv"

def ingest_kibor():
    df = pd.read_csv(CSV_PATH)
    df.columns = [c.lower().strip() for c in df.columns]

    df = df[["date", "value"]]
    df["country"] = "Pakistan"
    df["indicator"] = "KIBOR_3M"
    df["source"] = "SBP"
    df["frequency"] = "Daily"

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

    print("✅ 3-Month KIBOR ingestion completed successfully")

if __name__ == "__main__":
    ingest_kibor()