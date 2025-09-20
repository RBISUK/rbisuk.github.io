# OmniAssist — AI colleague who never cuts corners
### Problem
Repetitive online tasks soak hours and create inconsistency; regulators hate invisible automation.

### Primary Users
- Ops assistants
- Case handlers
- Compliance

### Core Capabilities
- Workflow builder with approvals and human-in-the-loop holds
- Step proofs: screenshots, selectors, API traces, timestamps
- Domain allowlists, PII redaction, rate limits

### Data Model (sketch)
- Run {id, workflowId, startedAt, steps[], artifacts[]}
- Step {action, selector, status, proofUri}
- Policy {allowlist[], piiRules[], limits}

### Workflows
- Portal scrape → CSV normalise → CRM update
- Contractor chase → polite nudge → receipt log

### Integrations
- Headless browser
- CRM API
- Email/SMS

### Security & Compliance
- Signed run receipts
- Operator attribution
- Revocable secrets

### KPIs
- Hours saved ↑
- Error rate ↓
- Proof coverage ↑

### Pricing Thoughts
- Per-seat or per-run
- Enterprise volume bundles

### Implementation Plan
- Day 1: top 2 workflows
- Week 1: approvals + redaction
- Week 2: scale out

### Risks & Mitigations
- Selector drift → visual anchors
- Blocked sites → allowlist governance

### Demo Scenario
- Show a run with proofs and a downloadable logbook

