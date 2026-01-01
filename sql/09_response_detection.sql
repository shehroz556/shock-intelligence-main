-- Response timing detection (batched, performance-safe version)
-- Scope: Top-N severe shocks, single indicator, materialized rolling stats

WITH rolling_stats AS MATERIALIZED (
    SELECT
        country,
        indicator,
        date,
        AVG(value) OVER (
            PARTITION BY country, indicator
            ORDER BY date
            ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING
        ) AS baseline,
        STDDEV(value) OVER (
            PARTITION BY country, indicator
            ORDER BY date
            ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING
        ) AS vol
    FROM time_series
),

top_severe_shocks AS (
    SELECT
        country,
        indicator,
        shock_date
    FROM shock_events
    WHERE severity_percentile >= 0.9
    ORDER BY severity_percentile DESC
    LIMIT 50
),

post_shock_window AS (
    SELECT
        s.country,
        s.indicator AS shock_indicator,
        t.indicator AS target_indicator,
        s.shock_date,
        t.date,
        (t.value - r.baseline) / NULLIF(r.vol, 0) AS deviation
    FROM top_severe_shocks s
    JOIN time_series t
      ON t.country = s.country
     AND t.date > s.shock_date
     AND t.date <= s.shock_date
         + ({max_response_window_days} || ' days')::INTERVAL
     AND t.indicator = 'USD_PKR'        -- single indicator (rotate later)
    JOIN rolling_stats r
      ON r.country = t.country
     AND r.indicator = t.indicator
     AND r.date = t.date
),

entry_signals AS (
    SELECT
        *,
        CASE
            WHEN ABS(deviation) >= {entry_threshold}
            THEN 1 ELSE 0
        END AS entry_flag
    FROM post_shock_window
),

confirmed_entries AS (
    SELECT
        *,
        SUM(entry_flag) OVER (
            PARTITION BY country, shock_indicator, target_indicator, shock_date
            ORDER BY date
            ROWS BETWEEN {confirmation_periods} - 1 PRECEDING AND CURRENT ROW
        ) AS entry_confirmation
    FROM entry_signals
),

response_starts AS (
    SELECT DISTINCT ON (
        country, shock_indicator, target_indicator, shock_date
    )
        country,
        shock_indicator,
        target_indicator,
        shock_date,
        date AS response_start
    FROM confirmed_entries
    WHERE entry_confirmation = {confirmation_periods}
    ORDER BY
        country, shock_indicator, target_indicator, shock_date, date
),

response_tracking AS (
    SELECT
        p.*,
        r.response_start
    FROM post_shock_window p
    JOIN response_starts r
      ON p.country = r.country
     AND p.shock_indicator = r.shock_indicator
     AND p.target_indicator = r.target_indicator
     AND p.shock_date = r.shock_date
     AND p.date >= r.response_start
),

exit_signals AS (
    SELECT
        *,
        CASE
            WHEN ABS(deviation) <= {exit_threshold}
            THEN 1 ELSE 0
        END AS exit_flag
    FROM response_tracking
),

confirmed_exits AS (
    SELECT
        *,
        SUM(exit_flag) OVER (
            PARTITION BY country, shock_indicator, target_indicator, shock_date
            ORDER BY date
            ROWS BETWEEN {exit_confirmation_periods} - 1 PRECEDING AND CURRENT ROW
        ) AS exit_confirmation
    FROM exit_signals
),

response_ends AS (
    SELECT DISTINCT ON (
        country, shock_indicator, target_indicator, shock_date
    )
        country,
        shock_indicator,
        target_indicator,
        shock_date,
        date AS response_end
    FROM confirmed_exits
    WHERE exit_confirmation = {exit_confirmation_periods}
    ORDER BY
        country, shock_indicator, target_indicator, shock_date, date
)

INSERT INTO response_events (
    country,
    shock_indicator,
    target_indicator,
    shock_date,
    response_start,
    response_end,
    response_lag_days,
    response_duration_days,
    max_response_deviation,
    avg_response_deviation,
    response_confirmed,
    response_type,
    detection_method,
    config_snapshot
)
SELECT
    r.country,
    r.shock_indicator,
    r.target_indicator,
    r.shock_date,
    r.response_start,
    e.response_end,
    (r.response_start - r.shock_date) AS response_lag_days,
    CASE
        WHEN e.response_end IS NOT NULL
        THEN (e.response_end - r.response_start)
        ELSE NULL
    END AS response_duration_days,
    MAX(ABS(t.deviation)) AS max_response_deviation,
    AVG(ABS(t.deviation)) AS avg_response_deviation,
    TRUE AS response_confirmed,
    CASE
        WHEN (r.response_start - r.shock_date) <= 7 THEN 'immediate'
        WHEN (r.response_start - r.shock_date) > 30 THEN 'delayed'
        ELSE 'moderate'
    END AS response_type,
    'threshold_persistence' AS detection_method,
    '{config_snapshot}'::JSONB
FROM response_starts r
JOIN response_tracking t
  ON t.country = r.country
 AND t.shock_indicator = r.shock_indicator
 AND t.target_indicator = r.target_indicator
 AND t.shock_date = r.shock_date
LEFT JOIN response_ends e
  ON e.country = r.country
 AND e.shock_indicator = r.shock_indicator
 AND e.target_indicator = r.target_indicator
 AND e.shock_date = r.shock_date
GROUP BY
    r.country,
    r.shock_indicator,
    r.target_indicator,
    r.shock_date,
    r.response_start,
    e.response_end
ON CONFLICT DO NOTHING;
