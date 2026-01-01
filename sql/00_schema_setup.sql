ALTER TABLE shock_events
ADD COLUMN IF NOT EXISTS severity_percentile NUMERIC,
ADD COLUMN IF NOT EXISTS persistence_periods INTEGER;

CREATE TABLE shock_spillovers (
    source_indicator TEXT,
    target_indicator TEXT,
    shock_date DATE,
    reaction_window_days INTEGER,
    avg_deviation NUMERIC,
    max_deviation NUMERIC,
    spillover_detected BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (source_indicator, target_indicator, shock_date)
);

CREATE TABLE response_events (
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
    response_confirmed BOOLEAN DEFAULT FALSE,
    response_type TEXT,
    detection_method TEXT,
    config_snapshot JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (country, shock_indicator, target_indicator, shock_date)
);
