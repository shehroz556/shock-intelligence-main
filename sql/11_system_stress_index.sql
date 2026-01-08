-- System Stress Index (SSI)
-- A stress regime exists when ≥2 indicators
-- have relative_severity ≥ 80 within a 30-day window

WITH severe_shocks AS (
    SELECT
        shock_date,
        indicator,
        relative_severity
    FROM shock_events_normalized
    WHERE relative_severity >= 80
),

rolling_stress AS (
    SELECT
        s1.shock_date AS reference_date,
        COUNT(DISTINCT s2.indicator) AS indicators_count,
        SUM(s2.relative_severity) AS stress_intensity,
        ARRAY_AGG(DISTINCT s2.indicator) AS indicators_involved
    FROM severe_shocks s1
    JOIN severe_shocks s2
      ON s2.shock_date BETWEEN
         s1.shock_date - INTERVAL '30 days'
         AND s1.shock_date
    GROUP BY s1.shock_date
),

systemic_days AS (
    SELECT *
    FROM rolling_stress
    WHERE indicators_count >= 2
),

grouped_days AS (
    SELECT
        reference_date,
        stress_intensity,
        indicators_involved,
        reference_date
        - ROW_NUMBER() OVER (ORDER BY reference_date)::INT AS grp
    FROM systemic_days
),

flattened AS (
    SELECT
        g.grp,
        g.reference_date,
        g.stress_intensity,
        ind.indicator
    FROM grouped_days g
    CROSS JOIN LATERAL unnest(g.indicators_involved) AS ind(indicator)
)

INSERT INTO system_stress_periods (
    stress_start,
    stress_end,
    indicators_involved,
    stress_intensity,
    dominant_indicator,
    config_snapshot
)
SELECT
    MIN(reference_date) AS stress_start,
    MAX(reference_date) AS stress_end,
    ARRAY_AGG(DISTINCT indicator) AS indicators_involved,
    SUM(stress_intensity) AS stress_intensity,

    -- ✅ deterministic dominant indicator
    (
        SELECT indicator
        FROM flattened f2
        WHERE f2.grp = flattened.grp
        GROUP BY indicator
        ORDER BY COUNT(*) DESC, indicator
        LIMIT 1
    ) AS dominant_indicator,

    jsonb_build_object(
        'stress_threshold', 80,
        'window_days', 30,
        'min_indicators', 2
    ) AS config_snapshot
FROM flattened
GROUP BY grp
ON CONFLICT DO NOTHING;

