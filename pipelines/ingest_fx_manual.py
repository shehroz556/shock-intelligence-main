import pandas as pd
from db_connection import get_connection

# Path to your FX CSV file (update this path)
CSV_PATH = r"C:\Users\Shehroz\Documents\shock-intelligence-main\data_raw\usd_pkr_daily.csv"

def ingest_fx_data():
    df = pd.read_csv(CSV_PATH)

    # Keep only required columns
    df = df[["Date", "Close"]]

    # Rename columns to match database schema
    df.rename(columns={
        "Date": "date",
        "Close": "value"
    }, inplace=True)

    # Add required metadata
    df["country"] = "Pakistan"
    df["indicator"] = "EXCHANGE_RATE"
    df["source"] = "Yahoo Finance"
    df["frequency"] = "Daily"

    conn = get_connection()
    cur = conn.cursor()

    for _, row in df.iterrows():
        cur.execute(
            """
            INSERT INTO time_series (country, indicator, date, value, source, frequency)
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

    print("✅ FX data ingestion completed successfully")

if __name__ == "__main__":
    ingest_fx_data()