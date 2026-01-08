CREATE OR REPLACE VIEW vw_shock_summary AS
SELECT
    indicator,
    shock_date,
    shock_value,
    baseline_value,
    deviation,
    z_score,
    severity_percentile,
    persistence_periods,
    detection_method,
    created_at
FROM shock_events;

CREATE OR REPLACE VIEW vw_spillover_events AS
SELECT
    source_indicator,
    target_indicator,
    shock_date,
    spillover_detected,
    avg_deviation,
    max_deviation,
    reaction_window_days,
    created_at
FROM shock_spillovers
WHERE spillover_detected = true;

CREATE OR REPLACE VIEW vw_time_series_clean AS
SELECT
    country,
    indicator,
    date,
    value,
    frequency,
    source
FROM time_series
WHERE indicator IN (
    'CPI',
    'USD_PKR',
    'KIBOR_3M',
    'POLICY_RATE'
);

CREATE OR REPLACE VIEW vw_shock_normalized AS
SELECT
    indicator,
    shock_date,
    z_score,
    severity_percentile,
    persistence_periods,
    relative_severity,
    global_shock_rank
FROM shock_events_normalized;

CREATE OR REPLACE VIEW vw_system_stress_periods AS
SELECT
    stress_start,
    stress_end,
    indicators_involved,
    stress_intensity,
    dominant_indicator,
    created_at
FROM system_stress_periods;

