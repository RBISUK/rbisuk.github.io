# Custom Sites & SEO-AI — Websites & SEO that survive audits
### Problem
Fancy sites fail audits: slow, inaccessible, privacy-messy; SEO collapses on review.

### Primary Users
- Marketing
- Compliance
- Web teams

### Core Capabilities
- Core Web Vitals tracking; WCAG 2.2 AA patterns baked-in
- Schema, sitemaps, robots, crawl budget sanity
- Consent-respecting analytics; zero dark patterns
- Topic maps + entity coverage + editorial guardrails

### Data Model (sketch)
- Page {url, vitals, a11yFindings[]}
- Content {entityGraph, sources, reviewCadence}

### Workflows
- Audit → fixes → validate → monitor
- Topic plan → drafts → review → publish → log

### Integrations
- Static hosts
- Search Console
- Analytics (privacy-clean)

### Security & Compliance
- Cookie minimisation
- Tag governance
- Change logs

### KPIs
- CLS/LCP/INP ↑
- Accessibility issues ↓
- Indexed pages ↑
- Organic conversions ↑

### Pricing Thoughts
- Fixed-fee build + retainers

### Implementation Plan
- Week 1: audit & plan
- Week 2: build & QA
- Week 3: ship & monitor

### Risks & Mitigations
- Plugin bloat → minimal stack
- Link rot → link checks

### Demo Scenario
- Render lighthouse-lite panel, show a11y checks

