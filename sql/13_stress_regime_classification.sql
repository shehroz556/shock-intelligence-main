WITH stats AS (
    SELECT
        percentile_cont(0.50) WITHIN GROUP (ORDER BY stress_intensity) AS p50,
        percentile_cont(0.85) WITHIN GROUP (ORDER BY stress_intensity) AS p85,
        percentile_cont(0.95) WITHIN GROUP (ORDER BY stress_intensity) AS p95
    FROM system_stress_periods
),

enriched AS (
    SELECT
        s.*,
        (s.stress_end - s.stress_start + 1) AS duration_days,
        CARDINALITY(s.indicators_involved) AS indicator_count,
        st.p50, st.p85, st.p95
    FROM system_stress_periods s
    CROSS JOIN stats st
)

INSERT INTO stress_regimes (
    stress_start,
    stress_end,
    stress_intensity,
    indicators_involved,
    duration_days,
    regime,
    classification_method,
    config_snapshot
)
SELECT
    stress_start,
    stress_end,
    stress_intensity,
    indicators_involved,
    duration_days,
    CASE
        WHEN stress_intensity >= p95
             OR (indicator_count >= 3 AND duration_days >= 14)
            THEN 'Crisis'
        WHEN stress_intensity >= p85
            THEN 'High Stress'
        WHEN stress_intensity >= p50
            THEN 'Elevated Stress'
        ELSE 'Low Stress'
    END AS regime,
    'percentile_rule_based' AS classification_method,
    jsonb_build_object(
        'p50', p50,
        'p85', p85,
        'p95', p95,
        'min_crisis_indicators', 3,
        'min_crisis_days', 14
    ) AS config_snapshot
FROM enriched
ON CONFLICT (stress_start) DO NOTHING;
