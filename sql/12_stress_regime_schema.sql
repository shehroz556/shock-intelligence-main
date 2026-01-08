CREATE TABLE IF NOT EXISTS stress_regimes (
    stress_start DATE PRIMARY KEY,
    stress_end DATE,
    stress_intensity NUMERIC,
    indicators_involved TEXT[],
    duration_days INTEGER,
    regime TEXT,
    classification_method TEXT,
    config_snapshot JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
