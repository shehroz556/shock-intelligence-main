
-- Compute persistence of detected economic shocks
ALTER TABLE shock_events
ADD COLUMN IF NOT EXISTS persistence_periods INTEGER;


WITH shock_baselines AS (
    SELECT
        s.country,
        s.indicator,
        s.shock_date,
        s.baseline_value,
        s.shock_value,
        CASE
            WHEN s.shock_value >= s.baseline_value THEN 1
            ELSE -1
        END AS shock_direction
    FROM shock_events s
),
post_shock_series AS (
    SELECT
        t.country,
        t.indicator,
        s.shock_date,
        t.date,
        t.value,
        s.baseline_value,
        s.shock_direction,
        CASE
            WHEN s.shock_direction = 1 AND t.value >= s.baseline_value THEN 1
            WHEN s.shock_direction = -1 AND t.value <= s.baseline_value THEN 1
            ELSE 0
        END AS persists
    FROM shock_baselines s
    JOIN time_series t
        ON s.country = t.country
        AND s.indicator = t.indicator
        AND t.date > s.shock_date
),
persistence_counts AS (
    SELECT
        country,
        indicator,
        shock_date,
        COUNT(*) FILTER (WHERE persists = 1) AS persistence_periods
    FROM post_shock_series
    GROUP BY country, indicator, shock_date
)
UPDATE shock_events s
SET persistence_periods = p.persistence_periods
FROM persistence_counts p
WHERE
    s.country = p.country
    AND s.indicator = p.indicator
    AND s.shock_date = p.shock_date;
