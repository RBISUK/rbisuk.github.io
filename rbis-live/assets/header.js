/* RBIS universal header (zero-network) */
(() => {
  const m = document.getElementById('rbis-header'); if(!m) return;
  const active = (m.dataset.active || '').toLowerCase();
  const logo = `
  <span class="crystal" aria-hidden="true">
    <svg class="spin" width="28" height="28" viewBox="0 0 32 32" role="img">
      <defs>
        <linearGradient id="g1" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stop-color="#9EC9FF"/><stop offset="1" stop-color="#2F39D7"/>
        </linearGradient>
      </defs>
      <g transform="translate(16,16)">
        <polygon points="0,-12 10,0 0,12 -10,0" fill="url(#g1)" stroke="#c7d2fe" stroke-width="1.2"/>
        <text x="0" y="5" text-anchor="middle" font-size="13" font-weight="900" fill="#ffffff">R</text>
      </g>
    </svg>
  </span>`;
  const links = ["Websites","Products","Dashboard","Reports","Careers","Managed","Legal","About","Contact"];
  const href = (t) => ({
    Websites:"#websites",Products:"#products",Dashboard:"/dashboard.html",
    Reports:"/reports.html",Careers:"/careers.html",Managed:"/managed.html",
    Legal:"/legal.html",About:"/about.html",Contact:"#contact"
  }[t] || "#");

  m.innerHTML = `
  <header>
    <div class="shell">
      <div class="bar">
        <a href="/index.html" class="brand" aria-label="RBIS home">${logo}<span>RBIS</span></a>
        <nav class="nav hidemd" aria-label="Primary">
          ${links.map(t => `<a href="${href(t)}" ${t.toLowerCase()===active?'class="active"':''}>${t}</a>`).join('')}
          <a class="btn brand" href="#contact">Enquire</a>
        </nav>
        <button id="rbisMenu" class="btn showmd" aria-expanded="false" aria-controls="rbisMobile">Menu</button>
      </div>
      <nav id="rbisMobile" class="showmd" aria-label="Mobile" style="display:none;padding:8px 0">
        <div style="display:grid;gap:6px">
          ${links.map(t => `<a class="btn" href="${href(t)}">${t}</a>`).join('')}
          <a class="btn brand" href="#contact">Enquire</a>
        </div>
      </nav>
    </div>
  </header>`;
  const btn = m.querySelector('#rbisMenu'), mob = m.querySelector('#rbisMobile');
  btn && btn.addEventListener('click', () => {
    const open = mob.style.display !== 'none';
    mob.style.display = open ? 'none' : 'block';
    btn.setAttribute('aria-expanded', String(!open));
  });
})();
