/* RBIS Reports UI — client-side filters + rendering */
(() => {
  const $ = sel => document.querySelector(sel);
  const $$ = sel => Array.from(document.querySelectorAll(sel));
  const root = $('#reports-root');
  if (!root) return;

  // Data source: <script id="report-data" type="application/json">…</script> (preferred)
  // Fallback to baked-in sample if missing.
  let data = [];
  const tag = $('#report-data');
  if (tag) { try { data = JSON.parse(tag.textContent.trim()); } catch(e){ console.warn('report-data parse', e); } }
  if (!data || !data.length) {
    data = [
      { id:'fraud-intel', title:'Fraud Intelligence Report', type:'Fraud', industry:'Insurance', cadence:'Ad-hoc', complexity:'Advanced', updated:'2025-09-01',
        tags:['patterns','link-analysis','behavioural'], summary:'Entity & network-level fraud patterns with behavioural markers.',
        details:'Includes network graph pivots, common modus operandi, anomaly windows, and recommended controls (claims rule stubs).'},
      { id:'claims-trends', title:'Claims Pattern Analysis', type:'Claims', industry:'Insurance', cadence:'Monthly', complexity:'Intermediate', updated:'2025-08-28',
        tags:['time-series','seasonality'], summary:'Outlier detection across claims, mapped to seasonality & cohort.',
        details:'Trend families, severity mix shift, spike attribution, and bias checks for false positives/negatives.'},
      { id:'competitor-behav', title:'Competitor Behavioural Lens', type:'Market', industry:'Legal/Corporate', cadence:'Quarterly', complexity:'Intermediate', updated:'2025-08-10',
        tags:['positioning','heuristics'], summary:'Competitive narratives and choice architecture decoded.',
        details:'Prospect frictions, commitment devices, pricing anchors, and copy heuristics that convert.'},
      { id:'trust-audit', title:'Trust & Safety Risk Audit', type:'Trust', industry:'Platform', cadence:'Ad-hoc', complexity:'Advanced', updated:'2025-09-12',
        tags:['abuse','risk','policy'], summary:'Abuse taxonomy coverage vs. policy, gaps & exploitability.',
        details:'Known-bad patterns, emergent vectors, red-team scenarios, detection & response maturity.'}
    ];
  }

  // UI wiring
  const ui = {
    q: $('#filter-q'), type: $('#filter-type'), industry: $('#filter-industry'),
    complexity: $('#filter-complexity'), cadence: $('#filter-cadence'),
    list: $('#reports'), count: $('#reports-count'), empty: $('#reports-empty')
  };

  function pass(r){
    const q = (ui.q?.value || '').toLowerCase();
    const hasQ = !q || [r.title, r.summary, r.details, (r.tags||[]).join(' ')].join(' ').toLowerCase().includes(q);
    const sel = (node) => (node && node.value) ? node.value : '';
    const checks = [
      v => !sel(ui.type)      || r.type===sel(ui.type),
      v => !sel(ui.industry)  || r.industry===sel(ui.industry),
      v => !sel(ui.complexity)|| r.complexity===sel(ui.complexity),
      v => !sel(ui.cadence)   || r.cadence===sel(ui.cadence),
    ].every(Boolean);
    return hasQ && checks;
  }

  function tag(t){ return `<span class="tag">${t}</span>`; }
  function row(r){
    const ts = (r.tags||[]).map(tag).join(' ');
    return `
      <article class="report-card" data-id="${r.id}">
        <header>
          <h3>${r.title}</h3>
          <a href="/contact.html" class="btn">Request</a>
        </header>
        <div class="tags">
          ${tag(r.type)} ${tag(r.industry)} ${tag(r.cadence)} ${tag(r.complexity)} ${ts}
        </div>
        <p>${r.summary}</p>
        <details class="disclosure"><summary>What’s inside</summary><div><p>${r.details}</p></div></details>
        <small class="muted">Last updated: ${r.updated}</small>
      </article>`;
  }

  function render(){
    const items = data.filter(pass).sort((a,b)=> (b.updated||'').localeCompare(a.updated||''));
    ui.list.innerHTML = items.map(row).join('');
    ui.count.textContent = items.length;
    ui.empty.classList.toggle('hidden', items.length>0);
  }

  ['input','change'].forEach(evt => root.addEventListener(evt, (e)=>{ if(e.target.closest('.filterbar')) render(); }, true));
  render();
})();
