CREATE OR REPLACE VIEW shock_events_normalized AS
WITH base AS (
    SELECT
        s.country,
        s.indicator,
        s.shock_date,
        s.z_score,
        s.severity_percentile,
        s.persistence_periods,

        -- persistence damping
        LN(1 + s.persistence_periods) AS persistence_weight,

        -- frequency adjustment
        CASE m.frequency
            WHEN 'Monthly' THEN 1.00
            WHEN 'Weekly'  THEN 0.75
            WHEN 'Daily'   THEN 0.50
            ELSE 0.75
        END AS frequency_weight

    FROM shock_events s
    LEFT JOIN indicator_metadata m
        ON s.indicator = m.indicator
)
SELECT
    *,
    severity_percentile
        * persistence_weight
        * frequency_weight
        AS relative_severity,

    RANK() OVER (
        ORDER BY
            severity_percentile
            * persistence_weight
            * frequency_weight DESC
    ) AS global_shock_rank
FROM base;
