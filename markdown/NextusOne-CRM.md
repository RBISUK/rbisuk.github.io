# NextusOne CRM — The CRM that speaks regulator + client
### Problem
CRMs ignore GDPR/PECR realities; teams invent risky workarounds.

### Primary Users
- CS teams
- Marketing (compliant)
- Legal

### Core Capabilities
- Lawful-basis selector + purpose notes at point of capture
- Retention schedules with auto-review tasks
- Consent capture, preference centre, PECR guards
- DSR workflows: access/rectify/erase with receipts

### Data Model (sketch)
- Person {id, lawfulBasis, retentionClock, consents[]}
- DSR {type, requester, dueBy, artifacts[]}

### Workflows
- Contact add → lawful basis prompt → retention start
- DSR ticket → evidence gather → deadline receipts

### Integrations
- Email/SMS
- Web forms
- Identity providers (SSO)

### Security & Compliance
- Field-level access
- Minimum-necessary data views
- DSR export hashes

### KPIs
- Unlawful sends ↓
- DSR on-time ↑
- Data minimisation ↑

### Pricing Thoughts
- Seat-based + compliance pack

### Implementation Plan
- Week 1: model + basis prompts
- Week 2: DSR flows
- Week 3: imports + SSO

### Risks & Mitigations
- Legacy imports → mapping tool
- Staff habits → nudges & defaults

### Demo Scenario
- Add contact, run erasure DSR, show receipts

