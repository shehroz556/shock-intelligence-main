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