(() => {
  const mount = document.getElementById('rbis-header'); 
  if (!mount) return;

  const crystal = `
  <span class="crystal" aria-hidden="true">
    <svg class="spin" width="32" height="32" viewBox="0 0 32 32" role="img">
      <defs>
        <linearGradient id="g1" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stop-color="#9EC9FF"/>
          <stop offset="1" stop-color="#2F39D7"/>
        </linearGradient>
        <radialGradient id="shine" cx="30%" cy="25%" r="70%">
          <stop offset="0" stop-color="rgba(255,255,255,.9)"/>
          <stop offset="1" stop-color="rgba(255,255,255,0)"/>
        </radialGradient>
        <mask id="rmask">
          <rect width="32" height="32" fill="white"/>
          <path d="M10 7v18h3v-6h3.7l3.7 6H23l-3.9-6c2.9-.8 4.3-2.5 4.3-5s-1.9-4.7-5.5-4.7H10zm3 2.6h4.2c2 0 3.2.8 3.2 2.4 0 1.6-1.2 2.4-3.2 2.4H13V9.6z" fill="black"/>
        </mask>
      </defs>
      <polygon points="16,2 28,10 28,22 16,30 4,22 4,10" 
               fill="url(#g1)" mask="url(#rmask)"/>
      <circle cx="10" cy="8" r="8" fill="url(#shine)"/>
    </svg>
  </span>`;
  const nav = [
    {href:"/index.html", label:"Home"},
    {href:"/demo.html", label:"Demo"},
    {href:"/dashboard.html", label:"Dashboard"},
    {href:"/articles/", label:"Articles"},
    {href:"/legal.html", label:"Legal"},
    {href:"/managed.html", label:"Managed Support"},
    {href:"/careers.html", label:"Careers"},
    {href:"#contact", label:"Contact", cta:true}
  ];
  const desktop = nav.map(l=>`<a class="btn ${l.cta?'brand':'ghost'}" href="${l.href}">${l.label}</a>`).join('');
  const mobile  = nav.map(l=>`<a href="${l.href}">${l.label}</a>`).join('');

  mount.innerHTML = `
  <link rel="stylesheet" href="/assets/header.css">
  <header role="banner">
    <div class="shell">
      <div class="bar">
        <a class="brand" href="/index.html" aria-label="RBIS home">${crystal}<span>RBIS</span></a>
        <nav class="nav" aria-label="Primary">${desktop}</nav>
        <button id="rbis-menu" class="menu-btn" aria-expanded="false" aria-controls="mnav" aria-label="Open menu">
          <svg width="22" height="22" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
        </button>
      </div>
      <nav id="mnav" aria-label="Mobile">${mobile}</nav>
    </div>
  </header>`;
  const btn = document.getElementById('rbis-menu');
  const mnav = document.getElementById('mnav');
  const setOpen = o => {
    mnav.style.display = o ? 'block' : 'none';
    btn.setAttribute('aria-expanded', o ? 'true' : 'false');
  };
  btn.addEventListener('click', () => setOpen(mnav.style.display !== 'block'));
  mnav.addEventListener('click', e => { if (e.target.tagName === 'A') setOpen(false); });
  let w = innerWidth;
  addEventListener('resize', () => { const nw = innerWidth; if ((w<980&&nw>=980)||(w>=980&&nw<980)) setOpen(false); w=nw; });
})();
