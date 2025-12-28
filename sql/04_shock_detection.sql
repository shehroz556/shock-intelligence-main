INSERT INTO shock_events (
    country,
    indicator,
    shock_date,
    shock_value,
    baseline_value,
    deviation,
    z_score,
    detection_method
)
SELECT
    country,
    indicator,
    date AS shock_date,
    value AS shock_value,
    rolling_mean AS baseline_value,
    value - rolling_mean AS deviation,
    (value - rolling_mean) / NULLIF(rolling_std, 0) AS z_score,
    'z_score_rolling' AS detection_method
FROM (
    SELECT
        country,
        indicator,
        date,
        value,
        AVG(value) OVER (
            PARTITION BY country, indicator
            ORDER BY date
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS rolling_mean,
        STDDEV(value) OVER (
            PARTITION BY country, indicator
            ORDER BY date
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS rolling_std
    FROM time_series
) t
WHERE
    rolling_mean IS NOT NULL
    AND ABS((value - rolling_mean) / NULLIF(rolling_std, 0)) >= 2
ON CONFLICT (country, indicator, shock_date) DO NOTHING;