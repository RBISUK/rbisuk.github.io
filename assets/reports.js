/* RBIS Reports UI — client-side filters + rendering */
(() => {
  const $  = s => document.querySelector(s);
  const $$ = s => Array.from(document.querySelectorAll(s));
  const root = $('#reports-root');
  if (!root) return;

  // Data source
  let data = [];
  const script = $('#report-data');
  try {
    data = script ? JSON.parse(script.textContent.trim()) : [];
  } catch { data = []; }
  if (!Array.isArray(data) || !data.length) {
    data = [
      {"id":"fraud-intel","title":"Fraud Intelligence Report","type":"Fraud","industry":"Insurance","cadence":"Ad-hoc","complexity":"Advanced","updated":"2025-09-01","tags":["patterns","link-analysis","behavioural"],"summary":"Entity & network-level fraud patterns with behavioural markers.","details":"Graph pivots, modus operandi, anomaly windows, rule suggestions."},
      {"id":"claims-trends","title":"Claims Pattern Analysis","type":"Claims","industry":"Insurance","cadence":"Monthly","complexity":"Intermediate","updated":"2025-08-28","tags":["time-series","seasonality"],"summary":"Outlier detection across cohorts and seasonality.","details":"Trend families, mix shift, spike attribution, reviewer guardrails."},
      {"id":"trust-audit","title":"Trust & Safety Risk Audit","type":"Trust","industry":"Platform","cadence":"Ad-hoc","complexity":"Advanced","updated":"2025-09-12","tags":["abuse","risk","policy"],"summary":"Abuse taxonomy coverage vs. policy; exploitability review.","details":"Known-bad patterns, emergent vectors, red-team scenarios, response maturity."}
    ];
  }

  // Build filterbar if empty
  let bar = root.querySelector('.filterbar');
  if (!bar) { bar = document.createElement('div'); bar.className = 'filterbar'; root.prepend(bar); }
  bar.innerHTML = `
    <div class="field">
      <label for="q">Search</label>
      <input type="search" id="q" placeholder="Title, tags, summary…">
    </div>
    <div class="field">
      <label for="type">Type</label>
      <select id="type"><option value="">All types</option></select>
    </div>
    <div class="field">
      <label for="industry">Industry</label>
      <select id="industry"><option value="">All industries</option></select>
    </div>
    <div class="field">
      <label for="sort">Sort</label>
      <select id="sort">
        <option value="updated:desc">Updated (newest)</option>
        <option value="updated:asc">Updated (oldest)</option>
        <option value="title:asc">Title (A–Z)</option>
      </select>
    </div>
  `;

  // Options
  const uniq = (arr) => [...new Set(arr.filter(Boolean).map(s=>String(s)))].sort((a,b)=>a.localeCompare(b));
  const types = uniq(data.map(d=>d.type));
  const industries = uniq(data.map(d=>d.industry));
  const typeSel = $('#type'), indSel = $('#industry');
  types.forEach(v => typeSel.insertAdjacentHTML('beforeend', `<option>${v}</option>`));
  industries.forEach(v => indSel.insertAdjacentHTML('beforeend', `<option>${v}</option>`));

  // Results containers
  let grid = root.querySelector('#reports');
  if (!grid) { grid = document.createElement('div'); grid.id = 'reports'; grid.className = 'grid cols-3'; root.append(grid); }
  let empty = root.querySelector('#reports-empty');
  if (!empty) { empty = document.createElement('div'); empty.id = 'reports-empty'; empty.className = 'empty hidden'; empty.textContent = 'No reports match your filters.'; root.append(empty); }

  // Render
  const renderCard = (r) => `
    <article class="card" id="${r.id}">
      <header>
        <h3>${r.title}</h3>
        <div class="meta">${r.type || ''} • ${r.industry || ''} • ${r.cadence || ''} • ${r.complexity || ''}</div>
      </header>
      <p>${r.summary || ''}</p>
      <div class="badges">
        ${(r.tags||[]).map(t=>`<span class="badge">#${t}</span>`).join('')}
      </div>
      <details>
        <summary>Details</summary>
        <div class="stack">
          <p>${r.details || ''}</p>
          ${r.updated ? `<div class="meta">Last updated: ${r.updated}</div>` : ''}
        </div>
      </details>
    </article>
  `;

  const state = { q:'', type:'', industry:'', sort:'updated:desc' };

  const apply = () => {
    const q = state.q.trim().toLowerCase();
    let out = data.filter(d => {
      if (state.type && d.type !== state.type) return false;
      if (state.industry && d.industry !== state.industry) return false;
      if (!q) return true;
      const hay = [d.title, d.summary, d.details, (d.tags||[]).join(' ')].join(' ').toLowerCase();
      return hay.includes(q);
    });

    const [key, dir] = state.sort.split(':');
    out.sort((a,b) => {
      let A = a[key] || '', B = b[key] || '';
      if (key === 'updated') { A = Date.parse(A)||0; B = Date.parse(B)||0; }
      if (A < B) return dir==='asc' ? -1 : 1;
      if (A > B) return dir==='asc' ? 1 : -1;
      return 0;
    });

    grid.innerHTML = out.map(renderCard).join('');
    empty.classList.toggle('hidden', out.length>0);

    // Deep-link: open details if hash matches
    if (location.hash) {
      const target = grid.querySelector(location.hash);
      if (target) {
        const det = target.querySelector('details'); det && (det.open = true);
        target.scrollIntoView({behavior:'smooth', block:'start'});
      }
    }
  };

  // Bind
  $('#q').addEventListener('input', e => { state.q = e.target.value; apply(); });
  typeSel.addEventListener('change', e => { state.type = e.target.value; apply(); });
  indSel.addEventListener('change', e => { state.industry = e.target.value; apply(); });
  $('#sort').addEventListener('change', e => { state.sort = e.target.value; apply(); });
  window.addEventListener('hashchange', apply);

  apply();
})();
