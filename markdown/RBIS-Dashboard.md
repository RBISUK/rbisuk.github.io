# RBIS Dashboard — Ops lit up, not buried in spreadsheets
### Problem
Leaders see lagging metrics and anecdote wars; nobody sees breaches early.

### Primary Users
- Exec
- Ops
- Legal
- Contractors

### Core Capabilities
- SLA early-warning with time-to-breach badges
- Disrepair risk heatmaps (severity × duration × vulnerability)
- Board views + operational drilldowns

### Data Model (sketch)
- KPI {name, formula, window}
- Alert {id, severity, etaToBreach}
- View {role, widgets[]}

### Workflows
- Ingest → normalise → score → alert → evidence link
- One-click board PDF with appendix links

### Integrations
- NextusOne CRM
- Claim-Fix-AI
- Sheets/CSV
- Email

### Security & Compliance
- Role scopes
- Export redaction
- Access logging

### KPIs
- Breach count ↓
- Mean time-to-resolve ↓
- Board queries answered ↑

### Pricing Thoughts
- Per-tenant
- Add-on widgets enterprise pack

### Implementation Plan
- Week 1: ingest + base KPIs
- Week 2: alerts + exports
- Week 3: role views

### Risks & Mitigations
- Garbage in → data contracts
- Alert fatigue → thresholds

### Demo Scenario
- Simulate 5 breaches, watch countdowns move

