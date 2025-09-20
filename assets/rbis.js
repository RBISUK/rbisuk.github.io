window.RBIS = window.RBIS || {};

RBIS.renderNav = () => {
  const html = `
  <nav class="rbis-nav">
    <a class="brand" href="/">RBIS</a>
    <div class="links">
      <a href="/offerings.html">Products & Services</a>
      <a href="/reports.html">Professional Reports</a>
      <a href="/trust.html">Trust Centre</a>
      <a href="/about.html">About</a>
      <a href="/careers.html">Careers</a>
    </div>
    <a class="cta" href="/contact.html">Contact Us</a>
  </nav>`;
  const t = document.getElementById('rbis-nav');
  if (t && !t.dataset.rendered){ t.innerHTML = html; t.dataset.rendered = "1"; }
};

// Simple details drawer (used by offerings + reports)
RBIS.openDrawer = (title, desc, list, href) => {
  let el = document.querySelector('.drawer');
  if (!el){
    el = document.createElement('div');
    el.className = 'drawer'; el.innerHTML = `<div class="inner">
      <button aria-label="Close" style="float:right" onclick="RBIS.closeDrawer()">✕</button>
      <h3 id="drawer-title"></h3>
      <p id="drawer-desc" class="sub"></p>
      <ul id="drawer-list"></ul>
      <p style="margin-top:12px"><a class="btn" id="drawer-cta" href="#">Enquire</a></p>
    </div>`;
    document.body.appendChild(el);
  }
  el.querySelector('#drawer-title').textContent = title;
  el.querySelector('#drawer-desc').textContent = desc || '';
  const ul = el.querySelector('#drawer-list'); ul.innerHTML = '';
  (list||[]).forEach(x=>{ const li=document.createElement('li'); li.textContent = `• ${x}`; ul.appendChild(li); });
  const a = el.querySelector('#drawer-cta'); a.href = href || '/contact.html';
  el.classList.add('open');
};
RBIS.closeDrawer = () => document.querySelector('.drawer')?.classList.remove('open');

document.addEventListener('DOMContentLoaded', RBIS.renderNav);
/* RBIS_DRAWER */
(function(){
  const DETAILS = {
    veridex: {
      title: "Veridex AI Funnel",
      html: `
        <p><strong>Smart intake that persuades ethically.</strong> Dynamic questions adapt to context (industry, risk, compliance) and tee up the right next action.</p>
        <ul>
          <li>Behavioural nudges (clarity, progress feedback, default safety)</li>
          <li>Audit-friendly event trail + exportable receipts</li>
          <li>Plug-in upsells: PACT (promises), OmniAssist (chasing), NextusOne (consent)</li>
        </ul>`
    },
    pact: {
      title: "PACT Ledger",
      html: `
        <p>Every promise captured, timed, and proven. Avoid “he-said-she-said”.</p>
        <ul>
          <li>Promise objects (terms, parties, due, remedy)</li>
          <li>Timers + nudges + escalation ladders</li>
          <li>Settlement playbooks + export packs</li>
        </ul>`
    },
    omniassist: {
      title: "OmniAssist",
      html: `
        <p>Automation with evidence. Every run has proofs (screens, selectors, timestamps).</p>
        <ul>
          <li>Approvals + allowlists + rate limits</li>
          <li>Human-in-the-loop holds for sensitive steps</li>
          <li>Signed run receipts; revocable secrets</li>
        </ul>`
    },
    nextusone: {
      title: "NextusOne CRM",
      html: `
        <p>CRM that speaks regulator + client. Lawful-basis + retention baked into capture.</p>
        <ul>
          <li>Consent & PECR guards; field-level access</li>
          <li>DSR workflows with deadline receipts</li>
        </ul>`
    },
    websites: {
      title: "Custom Sites & SEO-AI",
      html: `
        <p>Audit-proof sites. WCAG 2.2 AA, Core Web Vitals, schema & sitemaps done right.</p>
        <ul>
          <li>Topic maps + entity coverage + editorial guardrails</li>
          <li>Consent-respecting analytics; zero dark patterns</li>
        </ul>`
    },
    dashboard: {
      title: "RBIS Intelligence Dashboard",
      html: `
        <p>See breaches before they happen. Heatmaps, countdowns, board views.</p>
        <ul>
          <li>Role-based widgets; alert fatigue controls</li>
          <li>Drilldowns link back to evidence</li>
        </ul>`
    }
  };

  function ensureDrawer(){
    if (document.querySelector('.drawer')) return;
    const backdrop = Object.assign(document.createElement('div'), { className:'drawer-backdrop' });
    const drawer = Object.assign(document.createElement('aside'), { className:'drawer', role:'dialog', 'aria-modal':'true' });
    drawer.innerHTML = `
      <button class="close" aria-label="Close">×</button>
      <h3 id="drawer-title"></h3>
      <div class="body" id="drawer-body"></div>
      <div class="cta">
        <a class="button" href="/contact.html?topic=product" style="display:inline-flex;gap:8px;padding:10px 14px;background:linear-gradient(180deg,var(--brand),var(--brand2));border-radius:12px;color:#0a0f18;font-weight:700">Talk to RBIS</a>
      </div>`;
    document.body.append(backdrop, drawer);
    backdrop.addEventListener('click', close);
    drawer.querySelector('.close').addEventListener('click', close);
    function close(){ drawer.classList.remove('open'); backdrop.style.display='none'; document.body.style.removeProperty('overflow'); }
    return { drawer, backdrop, open(title, html){
      drawer.querySelector('#drawer-title').textContent = title;
      drawer.querySelector('#drawer-body').innerHTML = html;
      drawer.classList.add('open'); backdrop.style.display='block'; document.body.style.overflow='hidden';
    }};
  }

  document.addEventListener('DOMContentLoaded', () => {
    const env = ensureDrawer();
    if (!env) return;
    // Find product cards by id or data attr
    Object.keys(DETAILS).forEach(key=>{
      const el = document.getElementById(key) || document.querySelector(`[data-product="${key}"]`);
      if (!el) return;
      // Add button if missing
      if (!el.querySelector('[data-drawer-btn]')){
        const btn = document.createElement('a');
        btn.href = "#";
        btn.setAttribute('data-drawer-btn', key);
        btn.textContent = "View details";
        el.appendChild(btn);
      }
    });
    document.body.addEventListener('click', (e)=>{
      const a = e.target.closest('[data-drawer-btn]');
      if (!a) return;
      e.preventDefault();
      const key = a.getAttribute('data-drawer-btn');
      const item = DETAILS[key]; if (!item) return;
      env.open(item.title, item.html);
    });
  });
})();
