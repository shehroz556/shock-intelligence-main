CREATE TABLE IF NOT EXISTS response_events (
    country TEXT NOT NULL,
    shock_indicator TEXT NOT NULL,
    target_indicator TEXT NOT NULL,
    shock_date DATE NOT NULL,

    response_start DATE,
    response_end DATE,

    response_lag_days INTEGER,
    response_duration_days INTEGER,

    max_response_deviation NUMERIC,
    avg_response_deviation NUMERIC,

    response_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
    response_type TEXT,

    detection_method TEXT NOT NULL,
    config_snapshot JSONB,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (country, shock_indicator, target_indicator, shock_date)
);
