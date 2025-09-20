(function(){
  const nav = document.querySelector('.nav');
  const toggle = document.getElementById('nav-toggle');
  if (toggle) toggle.addEventListener('click', ()=> nav.classList.toggle('open'));
  // active link
  const here = location.pathname.toLowerCase();
  document.querySelectorAll('.nav a.link').forEach(a=>{
    const href = a.getAttribute('href')||'';
    if (href && here.endsWith(href.toLowerCase())) a.classList.add('active');
  });
})();

// === RBIS extras (reports) ===
window.RBIS = window.RBIS || {};
RBIS.openDrawer = function(title, bodyHTML){
  let b = document.querySelector('.drawer-backdrop');
  let d = document.querySelector('.drawer');
  if(!b){
    b = document.createElement('div'); b.className='drawer-backdrop';
    d = document.createElement('div'); d.className='drawer';
    d.innerHTML = `
      <div class="hd"><h3 id="drawer-title"></h3>
        <button id="drawer-close" class="btn-ghost" aria-label="Close">Close</button>
      </div>
      <div class="bd" id="drawer-body"></div>`;
    document.body.append(b,d);
    b.addEventListener('click', RBIS.closeDrawer);
    d.querySelector('#drawer-close').addEventListener('click', RBIS.closeDrawer);
  }
  d.querySelector('#drawer-title').textContent = title;
  d.querySelector('#drawer-body').innerHTML = bodyHTML;
  b.classList.add('open'); d.classList.add('open');
};
RBIS.closeDrawer = function(){
  document.querySelector('.drawer')?.classList.remove('open');
  document.querySelector('.drawer-backdrop')?.classList.remove('open');
};

// attach click handlers for [data-report]
document.addEventListener('click', (e)=>{
  const t = e.target.closest('[data-report]');
  if(!t) return;
  e.preventDefault();
  const id = t.getAttribute('data-report');
  const r = (window.REPORTS||[]).find(x=>x.id===id);
  if(!r) return;
  RBIS.openDrawer(r.name, `
    <p class="kicker">${r.group||'Professional Report'}</p>
    <p>${r.desc||''}</p>
    <ul class="clean">${(r.points||[]).map(x=>`<li>${x}</li>`).join('')}</ul>
    <div style="display:flex;gap:8px;margin-top:10px">
      <a class="btn" href="/contact.html?report=${encodeURIComponent(r.name)}">Request this report</a>
      <a class="btn-ghost" href="/reports.html#catalogue">View full catalogue</a>
    </div>
  `);
});
