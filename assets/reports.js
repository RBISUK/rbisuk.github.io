export const REPORTS = [
  { id:"hdr-risk-audit",        title:"Housing Disrepair Risk Audit",           cat:"Legal/Ops",    icon:"⚖️", price:495,  lead:"3–5d",  popularity:"popular", blurb:"Independent review of disrepair risk, chronology, and uphold exposure." },
  { id:"sla-breach-analysis",   title:"SLA Breach Analysis",                    cat:"Ops",          icon:"⏱️", price:395,  lead:"2–4d",  blurb:"Identify early-warning thresholds and quantify breach drivers by team and issue." },
  { id:"ombudsman-pack",        title:"Ombudsman Readiness Pack",               cat:"Legal",        icon:"📁", price:995,  lead:"5–7d",  blurb:"Audit-ready evidence pack: timeline, actions, comms, outcomes, receipts." },
  { id:"root-cause",            title:"Complaint Root Cause Analysis",          cat:"Ops",          icon:"🧭", price:495,  lead:"3–5d",  blurb:"From anecdotes to pattern: classify drivers and map fixes that stick." },
  { id:"damp-mould",            title:"Damp & Mould Evidence Review",           cat:"Legal/Ops",    icon:"🧪", price:395,  lead:"2–4d",  blurb:"Evidence completeness and severity scoring; clear remediation pointers." },
  { id:"chronology",            title:"Repairs Chronology Reconstruction",      cat:"Ops",          icon:"📜", price:495,  lead:"3–5d",  blurb:"Rebuild the full case history across channels; expose gaps and lags." },
  { id:"contractor-score",      title:"Contractor Performance Scorecard",       cat:"Ops/Vendor",   icon:"🛠️", price:395,  lead:"2–4d",  blurb:"On-time, first-time-fix, and communication KPIs with variance by trade." },
  { id:"exec-board-pack",       title:"Executive KPI Board Pack",               cat:"Exec",         icon:"📊", price:895,  lead:"5–7d",  popularity:"anchor", blurb:"Quarterly board pack with drilldowns and appendix links ready to ship." },
  { id:"risk-register",         title:"Board Risk Register Refresh",            cat:"Exec",         icon:"📋", price:695,  lead:"4–6d",  blurb:"Tidy risks, owners, and mitigations; align to what’s actually happening." },
  { id:"retention-review",      title:"Data Protection & Retention Review",     cat:"Compliance",   icon:"🔒", price:495,  lead:"3–5d",  blurb:"Lawful basis, minimisation, clocks—practical fixes without drama." },
  { id:"dsar-qa",               title:"GDPR Subject Access Response QA",        cat:"Compliance",   icon:"📮", price:295,  lead:"2–3d",  blurb:"Spot missing artifacts and risky redactions; ship on time." },
  { id:"pecr-sweep",            title:"PECR Comms Compliance Sweep",            cat:"Compliance",   icon:"📧", price:395,  lead:"2–4d",  blurb:"Consent, preferences, and contact policy—what’s actually being sent." },
  { id:"a11y-ux",               title:"Accessibility & UX Audit (WCAG 2.2 AA)", cat:"Web/SEO",      icon:"♿",  price:495,  lead:"3–5d",  blurb:"Common blockers, copy clarity, and quick wins; dev-ready tickets." },
  { id:"seo-tech",              title:"SEO Technical Site Audit",               cat:"Web/SEO",      icon:"��", price:495,  lead:"3–5d",  blurb:"Indexation, semantics, sitemaps, schema, crawl budget sanity." },
  { id:"web-vitals",            title:"Web Vitals Performance Report",          cat:"Web/SEO",      icon:"⚡",  price:395,  lead:"2–4d",  blurb:"LCP/CLS/INP with reproducible steps and perf diffs." },
  { id:"consent-health",        title:"Consent & Preferences Healthcheck",      cat:"Compliance",   icon:"✅", price:395,  lead:"2–4d",  blurb:"End-to-end capture and enforcement across forms, CRM, and sends." },
  { id:"pact-readiness",        title:"Promise Compliance (PACT Ledger) Readiness", cat:"Ops/Legal",icon:"🤝", price:495,  lead:"3–5d",  blurb:"Promises objectised; timers, escalations, and receipts that withstand scrutiny." },
  { id:"crm-quality",           title:"CRM Data Quality & De-duplication",      cat:"Data/CRM",     icon:"��", price:395,  lead:"2–4d",  blurb:"Duplicates, missing fields, and decay; practical clean-up plan." },
  { id:"cc-qa",                 title:"Contact Centre QA Calibration Pack",     cat:"Ops",          icon:"🎧", price:395,  lead:"2–4d",  blurb:"Scoring rubric, sample reviews, and coaching prompts." },
  { id:"journey-map",           title:"Multi-Channel Journey Mapping",          cat:"Ops/UX",       icon:"🗺️", price:695,  lead:"4–6d",  blurb:"Moments that matter; where to add proof and reduce friction." },
  { id:"portal-content",        title:"Portal Content Clarity Review",          cat:"UX/Content",   icon:"🧾", price:295,  lead:"2–3d",  blurb:"Reduce tickets with precise language and better defaults." },
  { id:"evidence-score",        title:"Evidence Completeness Score",            cat:"Legal/Ops",    icon:"🧾", price:295,  lead:"2–3d",  blurb:"Objective coverage vs. requirement; gaps with examples." },
  { id:"escalation-review",     title:"Escalation Ladder Effectiveness",        cat:"Ops",          icon:"🪜", price:295,  lead:"2–3d",  blurb:"Where escalations save time vs. create loops; tune thresholds." },
  { id:"alert-tuning",          title:"Early-Warning Alert Tuning",             cat:"Ops/Data",     icon:"🚨", price:395,  lead:"2–4d",  blurb:"Signal vs. noise; actionable alerts with receipts." },
  { id:"stock-health",          title:"Repairs Stock Health Heatmap",           cat:"Ops/Data",     icon:"🌡️", price:495,  lead:"3–5d",  blurb:"Where backlog, severity, and vulnerability collide." },
  { id:"tenancy-integrity",     title:"Tenancy Data Integrity Report",          cat:"Data/CRM",     icon:"🧬", price:395,  lead:"2–4d",  blurb:"Key joins (UPRN etc.), broken refs, and confidence scoring." },
  { id:"vendor-controls",       title:"Vendor Risk & Controls Snapshot",        cat:"Vendor",       icon:"🏷️", price:495,  lead:"3–5d",  blurb:"Access control, data flows, receipts; pragmatic actions." },
  { id:"tna-ops",               title:"Training Needs Analysis (Ops)",          cat:"People/Ops",   icon:"📚", price:395,  lead:"2–4d",  blurb:"What actually needs practice; micro-lessons mapped to errors." },
  { id:"policy-gap",            title:"Policy-to-Process Gap Analysis",         cat:"Compliance",   icon:"🧩", price:495,  lead:"3–5d",  blurb:"Where policies diverge from day-to-day; fix with defaults." },
  { id:"change-governance",     title:"Change Log & Governance Review",         cat:"Compliance",   icon:"🗂️", price:395,  lead:"2–4d",  blurb:"Evidence of control, approvals, and auditable rollouts." },
  { id:"quarterly-spotlight",   title:"Quarterly Compliance Spotlight",         cat:"Exec",         icon:"🔦", price:895,  lead:"5–7d",  blurb:"A focused deep-dive you can show to the board and regulator." }
];

export const METRICS = {
  orders30d: 24, onTime: "99.2%", tatAvg: "3–5 days", nps: "4.9/5", capacityNote: "Limited slots this month"
};

export function initReports(){
  const $c = (sel,root=document)=>root.querySelector(sel);
  const $a = (sel,root=document)=>[...root.querySelectorAll(sel)];
  const wrap = $c('#reports-root');
  const countEl = $c('#rep-count'); countEl.textContent = REPORTS.length.toString();
  const npsEl = $c('#rep-nps'); npsEl.textContent = METRICS.nps;
  const tatEl = $c('#rep-tat'); tatEl.textContent = METRICS.tatAvg;
  const onTimeEl = $c('#rep-on-time'); onTimeEl.textContent = METRICS.onTime;
  const capEl = $c('#rep-capacity'); capEl.textContent = METRICS.capacityNote;

  // Try to fetch version.json for "updated" stamp
  fetch('version.json').then(r=>r.ok?r.json():null).then(j=>{
    if(j && j.deployed) { const e = $c('#rep-updated'); if(e) e.textContent = new Date(j.deployed).toLocaleString(); }
  }).catch(()=>{});

  const grid = $c('#rep-grid');
  const tmpl = (r)=>`
    <article class="card" data-cat="${r.cat}">
      <div class="body">
        ${r.popularity==='anchor' ? `<span class="flag">Recommended</span>` : r.popularity==='popular' ? `<span class="flag" style="background:#1a4cff">Popular</span>`:``}
        <div class="badge">${r.icon}<span>${r.cat}</span></div>
        <h3 style="margin:.5rem 0 0">${r.title}</h3>
        <p class="muted" style="margin:.4rem 0">${r.blurb}</p>
        <div class="price">£${r.price}</div>
        <div class="meta"><span>Lead time ${r.lead}</span></div>
        <div class="cta">
          <a class="btn primary" href="contact.html?report=${encodeURIComponent(r.id)}">Book</a>
          <a class="btn ghost" href="contact.html?sample=${encodeURIComponent(r.id)}">See sample</a>
        </div>
      </div>
    </article>`;

  function render(list){ grid.innerHTML = list.map(tmpl).join(''); }
  render(REPORTS);

  // Filters + search
  let activeCat = 'All';
  const pills = $a('[data-cat-pill]');
  pills.forEach(p=>p.addEventListener('click',()=>{
    pills.forEach(x=>x.classList.remove('active'));
    p.classList.add('active');
    activeCat = p.dataset.catPill;
    apply();
  }));
  const q = $c('#rep-search'); q.addEventListener('input', apply);

  function apply(){
    const term = q.value.trim().toLowerCase();
    let list = REPORTS;
    if(activeCat !== 'All') list = list.filter(r=>r.cat.toLowerCase().includes(activeCat.toLowerCase()));
    if(term) list = list.filter(r=> (r.title+r.blurb+r.cat).toLowerCase().includes(term));
    render(list);
  }
}
