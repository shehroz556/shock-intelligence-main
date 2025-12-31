Shock Intelligence Engine – Pakistan
Overview

This project is a research-driven analytical system designed to identify inflation shocks in Pakistan and examine how those shocks propagate through financial markets, liquidity conditions, and monetary policy responses over time.

Rather than focusing on prediction, the system emphasizes detection, severity, and timing. It aims to make macroeconomic stress more legible by separating routine variation from system-level shocks and observing how different parts of the economy respond.

The project reflects my background in economics and applied data analysis, combining statistical rigor with interpretability.

Motivation

Macroeconomic stress rarely unfolds in a linear or synchronized way.

Inflation shocks may emerge suddenly, markets often react immediately, liquidity conditions tighten selectively, and institutional policy responses tend to arrive later and only after sustained pressure. Traditional analysis often treats these dynamics as simultaneous or relies on static thresholds that fail to adapt to changing economic regimes.

This project was built to address that gap by:

Detecting shocks relative to historical context

Measuring severity rather than binary events

Observing transmission across markets and institutions without assuming causality

Methodology (High Level)
Shock Detection

Inflation shocks are identified using rolling statistical baselines rather than fixed thresholds. This allows the system to adapt to structural changes in inflation behavior over time.

Severity Scoring

Each detected shock is assigned a relative severity score, capturing both magnitude and persistence. Severity is evaluated within the historical distribution rather than against arbitrary cutoffs.

Transmission Analysis

Once shocks are identified, the system examines how stress propagates across:

Exchange rate movements

Short-term interest rates as a proxy for liquidity stress

Policy rate adjustments as institutional response

Silence or inaction is treated as informative rather than as missing data.

Data Sources

The current implementation focuses on Pakistan and includes:

Consumer Price Index (CPI)

USD/PKR exchange rate

3-month KIBOR

Policy (target) rate

Data are standardized and ingested into a relational database to support reproducible analysis.

Dashboard Interpretation Guide

The accompanying dashboard is structured as a narrative:

CPI Shock Timeline
Identifies when inflation stress deviates significantly from historical norms.

CPI vs Exchange Rate
Examines how currency markets respond during high-severity inflation periods using year-over-year changes to preserve comparability.

CPI vs KIBOR
Observes liquidity tightening behavior relative to inflation stress rather than inflation levels.

CPI vs Policy Rate
Highlights delayed and selective institutional responses, emphasizing persistence and severity over short-term volatility.

The dashboard is designed for interpretation, not prediction.

What This Project Is (and Is Not)

This project is:

A shock detection and transmission framework

Statistically adaptive and historically grounded

Focused on interpretability and timing

This project is not:

A forecasting model

A causal inference claim

A rule-based alert system

Current Status

The core shock detection engine, severity scoring, data ingestion pipelines, and visualization layer are complete. The project is actively evolving, with future work focused on deeper spillover analysis, automation, and extensibility to other economies.

Why This Matters

Clearer identification and interpretation of macroeconomic stress can support better research, more informed policy discussions, and improved decision-making under uncertainty.

This project represents an effort to bring structure and clarity to complex macro dynamics without oversimplification.

About the Author

Built by an economist with a background in development economics and data analytics, with experience in applied policy research and large-scale data systems.
