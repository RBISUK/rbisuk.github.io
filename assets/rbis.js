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
