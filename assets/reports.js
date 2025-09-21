/* RBIS Reports UI — minimal, robust, accessible */
(() => {
  const root = document.querySelector('#reports-root');
  if (!root) return;

  const el = (tag, attrs={}, kids=[]) => {
    const n = document.createElement(tag);
    Object.entries(attrs).forEach(([k,v]) => (v!=null) && n.setAttribute(k, v));
    kids.forEach(k => n.append(k));
    return n;
  };

  const dataTag = document.querySelector('#report-data[type="application/json"]');
  let data = [];
  try { data = dataTag ? JSON.parse(dataTag.textContent.trim()) : []; }
  catch(e){ console.warn('report-data JSON parse failed', e); }

  const list = root.querySelector('#reports') || root.appendChild(el('div',{id:'reports',class:'grid cols-3'}));
  const empty = root.querySelector('#reports-empty') || root.appendChild(el('div',{id:'reports-empty',class:'empty hidden'},['No reports match your filters.']));

  // Filters (type/industry/cadence/complexity/tags + search)
  const fb = root.querySelector('.filterbar') || root.insertBefore(el('div',{class:'filterbar'}), list);
  const f = {
    q: el('input',{type:'search',placeholder:'Search reports…','aria-label':'Search reports'}),
    type: el('select',{'aria-label':'Type'}),
    industry: el('select',{'aria-label':'Industry'}),
    cadence: el('select',{'aria-label':'Cadence'}),
    complexity: el('select',{'aria-label':'Complexity'}),
    tags: el('select',{'aria-label':'Tag'})
  };
  const uniq = a => [...new Set(a.filter(Boolean))].sort();
  const from = k => uniq(data.map(d => Array.isArray(d[k])? null : d[k]));
  const tagset = uniq(data.flatMap(d => d.tags||[]));

  const opt = (sel, items) => {
    sel.replaceChildren(el('option',{value:''},['All']));
    items.forEach(v => sel.append(el('option',{value:v},[v])));
  };
  opt(f.type, from('type')); opt(f.industry, from('industry')); opt(f.cadence, from('cadence'));
  opt(f.complexity, from('complexity')); opt(f.tags, tagset);

  fb.replaceChildren(
    el('div',{},[f.q]),
    el('div',{},[f.type]), el('div',{},[f.industry]),
    el('div',{},[f.cadence]), el('div',{},[f.complexity]), el('div',{},[f.tags])
  );

  const matches = (r) => {
    const q = f.q.value.trim().toLowerCase();
    const pick = (k) => (r[k]||'').toString().toLowerCase();
    const inTags = (q && (r.tags||[]).some(t => t.toLowerCase().includes(q)));
    const textHit = !q || [pick('title'), pick('summary'), pick('details'), pick('industry'), pick('type')].some(v => v.includes(q)) || inTags;
    const selHit = (k,sel) => !sel.value || (Array.isArray(r[k]) ? r[k].includes(sel.value) : (r[k]===sel.value));
    const tagHit = !f.tags.value || (r.tags||[]).includes(f.tags.value);
    return textHit && selHit('type',f.type) && selHit('industry',f.industry) && selHit('cadence',f.cadence) && selHit('complexity',f.complexity) && tagHit;
  };

  const card = (r) => {
    const a = el('article',{class:'card',id:r.id});
    a.append(
      el('h3',{},[r.title]),
      el('p',{},[r.summary||'']),
      el('dl',{},[
        el('dt',{},['Type']), el('dd',{},[r.type||'-']),
        el('dt',{},['Industry']), el('dd',{},[r.industry||'-']),
        el('dt',{},['Cadence']), el('dd',{},[r.cadence||'-']),
        el('dt',{},['Complexity']), el('dd',{},[r.complexity||'-']),
        el('dt',{},['Updated']), el('dd',{},[r.updated||'-'])
      ]),
      el('details',{},[
        el('summary',{},['Details']),
        el('p',{},[r.details||'No additional details provided.']),
        r.tags?.length ? el('p',{},['Tags: ', r.tags.join(', ')]) : null
      ].filter(Boolean))
    );
    return a;
  };

  const render = () => {
    const items = data.filter(matches);
    list.replaceChildren(...items.map(card));
    empty.classList.toggle('hidden', items.length>0);
  };

  [f.q,f.type,f.industry,f.cadence,f.complexity,f.tags].forEach(c => c.addEventListener('input', render));
  // hash deep-link
  if (location.hash) {
    const id = location.hash.slice(1);
    setTimeout(() => document.getElementById(id)?.scrollIntoView({behavior:'smooth',block:'start'}), 50);
  }
  render();
})();
