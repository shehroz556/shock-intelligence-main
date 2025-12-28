-- Compute severity scores for detected shocks using percentile ranking

ALTER TABLE shock_events
ADD COLUMN severity_percentile NUMERIC;

WITH ranked_shocks AS (
    SELECT
        country,
        indicator,
        shock_date,
        ABS(z_score) AS abs_z,
        PERCENT_RANK() OVER (
            PARTITION BY indicator
            ORDER BY ABS(z_score)
        ) * 100 AS severity_pct
    FROM shock_events
)
UPDATE shock_events s
SET severity_percentile = r.severity_pct
FROM ranked_shocks r
WHERE
    s.country = r.country
    AND s.indicator = r.indicator
    AND s.shock_date = r.shock_date;