-- Core time series table
CREATE TABLE time_series (
    country          TEXT NOT NULL,
    indicator         TEXT NOT NULL,
    date              DATE NOT NULL,
    value             NUMERIC NOT NULL,
    source            TEXT,
    frequency         TEXT,
    PRIMARY KEY (country, indicator, date)
);

-- Indicator metadata
CREATE TABLE indicator_metadata (
    indicator         TEXT PRIMARY KEY,
    unit              TEXT,
    frequency         TEXT,
    description       TEXT,
    source            TEXT
);

-- Detected shock events
CREATE TABLE shock_events (
    country           TEXT,
    indicator         TEXT,
    shock_date        DATE,
    shock_value       NUMERIC,
    baseline_value    NUMERIC,
    deviation         NUMERIC,
    z_score           NUMERIC,
    detection_method  TEXT,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
