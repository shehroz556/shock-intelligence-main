-- Detect cross-indicator spillovers following economic shocks
CREATE TABLE shock_spillovers (
    source_indicator      TEXT,
    target_indicator      TEXT,
    shock_date            DATE,
    reaction_window_days  INTEGER,
    avg_deviation         NUMERIC,
    max_deviation         NUMERIC,
    spillover_detected    BOOLEAN,
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (source_indicator, target_indicator, shock_date)
);


-- Detect cross-indicator spillovers following CPI shocks (exclude self-effects)

WITH cpi_shocks AS (
    SELECT
        country,
        shock_date
    FROM shock_events
    WHERE indicator = 'CPI'
),
target_baselines AS (
    SELECT
        t.country,
        t.indicator,
        t.date,
        t.value,
        AVG(t.value) OVER (
            PARTITION BY t.country, t.indicator
            ORDER BY t.date
            ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING
        ) AS baseline,
        STDDEV(t.value) OVER (
            PARTITION BY t.country, t.indicator
            ORDER BY t.date
            ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING
        ) AS vol
    FROM time_series t
),
reaction_window AS (
    SELECT
        s.shock_date,
        b.indicator AS target_indicator,
        b.date,
        (b.value - b.baseline) / NULLIF(b.vol, 0) AS deviation
    FROM cpi_shocks s
    JOIN target_baselines b
        ON b.date > s.shock_date
        AND b.date <= s.shock_date + INTERVAL '30 days'
        AND b.indicator <> 'CPI'   -- 🔑 critical fix
)
INSERT INTO shock_spillovers (
    source_indicator,
    target_indicator,
    shock_date,
    reaction_window_days,
    avg_deviation,
    max_deviation,
    spillover_detected
)
SELECT
    'CPI' AS source_indicator,
    target_indicator,
    shock_date,
    30 AS reaction_window_days,
    AVG(deviation) AS avg_deviation,
    MAX(ABS(deviation)) AS max_deviation,
    MAX(ABS(deviation)) >= 2 AS spillover_detected
FROM reaction_window
GROUP BY shock_date, target_indicator
HAVING COUNT(deviation) > 0
ON CONFLICT DO NOTHING;
