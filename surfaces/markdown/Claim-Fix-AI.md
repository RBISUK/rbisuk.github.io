# Claim-Fix-AI — Turn tenant complaints into audit-ready cases
### Problem
Repairs & disrepair complaints sprawl across emails, phones, portals; missing chronology elevates uphold risk.

### Primary Users
- Contact centre
- Repairs ops
- Legal/Complaints
- Contractors

### Core Capabilities
- Structured intake (address, tenancy, taxonomy, severity) with evidential prompts
- SLA timers with breach receipts and automatic chronology updates
- Evidence capture (photos/video, damp/mould readings, reports)
- One-click ‘Audit Pack’ (timeline, actions, comms, outcomes)

### Data Model (sketch)
- Case {id, tenancy, property(Uprn), issue(type, severity), reportedAt}
- Event {timestamp, actor, channel, payloadHash}
- Evidence {type, uri, sha256, capturedBy}
- SLA {triage, deadlines[], breaches[]}

### Workflows
- Triage → schedule → inspect → remediate → follow-up → close
- Breach detection → escalation ladder → apology/compensation review
- Export pack → Ombudsman/board pack ready

### Integrations
- Email/SMS
- Contractor portals
- Asset systems (UPRN)
- Document store (R2/S3)

### Security & Compliance
- PII minimisation
- Role-based views
- Immutable event hash chain
- Redaction on export

### KPIs
- Uphold rate ↓
- Time-to-fix ↓
- SLA breach rate ↓
- Evidence completeness ↑

### Pricing Thoughts
- Starter: intake + packs
- Pro: timers + escalations
- Enterprise: integrations + SSO

### Implementation Plan
- Week 1: intake + timers
- Week 2: evidence + exports
- Week 3: integrations + training

### Risks & Mitigations
- Low media quality → guided capture
- Data silos → CSV/API importers

### Demo Scenario
- Upload 3 photos, generate timeline, download pack in 30s

