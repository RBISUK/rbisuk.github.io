# PACT Ledger — Every promise made, kept, or called to account
### Problem
Promises live in inboxes and memory; disputes devolve into he-said-she-said.

### Primary Users
- Suppliers
- Legal
- Ops
- Finance

### Core Capabilities
- Promise objects with terms, parties, due dates, remedies
- Timers + nudges + escalation ladders
- Settlement playbooks and exportable evidence packs

### Data Model (sketch)
- Promise {id, terms, parties[], due, remedy}
- Event {ts, actor, action, artifactHash}
- Settlement {offers[], agreements[], receipts[]}

### Workflows
- Capture → confirm → monitor → escalate → settle
- Import from email/WhatsApp → objectise → track

### Integrations
- Email ingestion
- CRM
- Doc store

### Security & Compliance
- Immutable event trail
- Signature receipts
- Open-standard exports

### KPIs
- Late promises ↓
- Time-to-settle ↓
- Evidence completeness ↑

### Pricing Thoughts
- Per-ledger volume
- Enterprise SSO + retention controls

### Implementation Plan
- Week 1: capture + objects
- Week 2: timers + nudges
- Week 3: settlement + exports

### Risks & Mitigations
- Ambiguous terms → templates
- Stakeholder buy-in → quick wins

### Demo Scenario
- Ingest email thread, mint a Promise, show countdown

