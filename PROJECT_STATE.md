# Project State — Shock Intelligence Engine

## Project Overview
This project is a research-oriented macroeconomic shock intelligence system designed to detect statistically unusual movements in economic indicators and evaluate their severity, persistence, and spillover effects across markets and policy transmission channels.

The system prioritizes conservative inference, transparency, and reproducibility over prediction or narrative fitting.

---

## Current Status
*Phase:* Automation & Repeatability completed  
*System State:* Fully functional and idempotent  
*Execution Mode:* One-command engine execution via Python

---

## Indicators Currently in Scope

### 1. Consumer Price Index (CPI)
- Country: Pakistan
- Frequency: Monthly
- Role: Primary shock origin indicator
- Status: Ingested and operational
- Used for: Shock detection, severity scoring, persistence analysis

### 2. Exchange Rate (PKR/USD)
- Frequency: Daily
- Role: Fast-moving market reaction indicator
- Status: Automated ingestion via Python completed
- Used for: Spillover detection from CPI shocks

### 3. Money Market Rate
- Frequency: Monthly
- Role: Proxy for monetary policy transmission and liquidity stress
- Status: Data acquisition pending
- Note: Used explicitly as a proxy, not as a policy decision variable

---

## Key Design Decisions (Locked In)

- The system does not attempt causal inference.
- Spillovers are interpreted as temporal co-movements beyond historical volatility.
- Policy rate data was deliberately excluded due to lack of clean, machine-readable availability.
- Money market rate is used instead as a clearly labeled proxy.
- SQL logic is idempotent and safe for repeated execution.
- Raw data is not stored in the repository.
- The repository is public to document methodology and system evolution.

---

## System Architecture

### Data Storage
- PostgreSQL database
- Core table: time_series
- Derived tables: shock_events, shock_spillovers

### Automation
- Python used for data ingestion and orchestration
- psycopg2 for database connectivity
- pandas for CSV ingestion and normalization

### Engine Execution
- run_engine.py executes all analytical SQL in sequence:
  - Shock detection
  - Severity scoring
  - Persistence detection
  - Spillover detection

---

## Key Artifacts

- SQL logic for detection and analysis located in /sql
- Python pipelines located in /pipelines
- Shock interpretation documented in /docs/shock_brief_2022_04_cpi.md
- This file documents the current project state

---

## Last Confirmed Milestone
- One-command execution of full shock intelligence engine completed successfully
- CPI to exchange rate spillover empirically detected
- System verified to be repeatable without schema conflicts

---

## Immediate Next Step
- Acquire and validate Pakistan money market rate data from a reliable source
- Prepare clean monthly CSV
- Ingest data using a dedicated Python ingestion script
- Re-run engine to evaluate CPI to money market spillovers
- Update shock brief with institutional transmission analysis

---

## Future Extensions (Not Yet Started)
- Confidence scoring for shocks
- Additional indicators (e.g., oil prices)
- Feature extraction for ML modeling
- Periodic shock monitoring output
- Potential research or policy-oriented dissemination

---

## Usage Note
This project is an active research and engineering system under continuous development. Outputs are exploratory and intended for analytical insight, not forecasting or policy prescription.


#Update
# Project State — Shock Intelligence Engine (Pakistan)

## Project Purpose
This project is a research-driven macroeconomic shock detection and transmission system focused on Pakistan. The goal is to identify inflation shocks relative to historical context, measure their severity and persistence, and observe how stress propagates through markets, liquidity, and policy responses over time.

The system prioritizes interpretability, timing, and severity rather than prediction or causal claims.

---

## Data Integrated
The following datasets have been ingested, standardized, and validated:

- Consumer Price Index (CPI)
- USD/PKR exchange rate
- 3-month KIBOR
- Policy (target) rate

All data are stored in a relational PostgreSQL database and exposed via analytical views.

---

## Core Methodology
- Inflation shocks are detected using rolling statistical baselines rather than fixed thresholds.
- Each shock is assigned a relative severity score based on magnitude and persistence.
- Transmission analysis examines how shocks relate temporally to:
  - Exchange rate movements
  - Short-term interest rate (liquidity) responses
  - Policy rate decisions
- Periods of inaction are treated as informative signals, not missing data.

---

## Database & Pipeline Status
- PostgreSQL schema finalized
- Time-series ingestion pipelines implemented and tested
- Shock detection and severity scoring SQL scripts completed
- Spillover logic implemented and verified
- Re-ingestion and resets tested successfully

---

## Visualization Layer
A Power BI dashboard has been built with the following narrative flow:

1. CPI Shock Timeline  
   Shows relative severity of inflation deviations from rolling historical baselines.

2. CPI vs Exchange Rate  
   Uses year-over-year percentage changes for both CPI and USD/PKR to preserve unit comparability and observe market responses during high-severity periods.

3. CPI vs KIBOR  
   Examines liquidity tightening relative to inflation stress rather than inflation levels.

4. CPI vs Policy Rate  
   Highlights delayed and selective institutional responses, emphasizing persistence and severity over short-term volatility.

A proper DateTable has been implemented in Power BI, and all YoY and indexed measures are functioning correctly.

---

## Current Status
Core system is complete and stable.
Dashboard narrative finalized.
GitHub README written to mirror analytical and visual narrative.

The project is now in a polish-and-extension phase rather than a build-from-scratch phase.

---

## Constraints & Philosophy
- No forecasting or causal claims are made.
- Focus remains on detection, severity, and timing.
- Statistical rigor and clarity take precedence over visual complexity.

---

## Next Intended Directions
- Documentation and portfolio packaging
- Optional automation and scheduling
- Extension to additional indicators or countries
- Potential transformation into a reusable analytical framework