CREATE TABLE IF NOT EXISTS system_stress_periods (
    stress_start DATE PRIMARY KEY,
    stress_end DATE NOT NULL,
    indicators_involved TEXT[],
    stress_intensity NUMERIC,
    dominant_indicator TEXT,
    config_snapshot JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
