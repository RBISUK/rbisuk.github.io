// Mobile nav
const toggle = document.querySelector('.nav-toggle');
const menu = document.getElementById('primary-menu');
if (toggle && menu) {
  toggle.addEventListener('click', () => {
    const open = menu.classList.toggle('open');
    toggle.setAttribute('aria-expanded', String(open));
  });
}

// Fade-in on scroll
const io = new IntersectionObserver(
  entries => entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('in'); }),
  { threshold: 0.14 }
);
document.querySelectorAll('.fade').forEach(el => io.observe(el));

// Active nav via data-page
(function(){
  const page = document.body.dataset.page;
  if (!page) return;
  const link = document.querySelector(`.nav-list a[href="${page}.html"]`);
  if (link){ link.classList.add('active'); link.setAttribute('aria-current','page'); }
})();

// Count-up stats
document.querySelectorAll('.stat-num[data-count]').forEach(el=>{
  const target = Number(el.getAttribute('data-count'))||0;
  const start = performance.now(), dur = 900;
  const step = t => { const p = Math.min((t-start)/dur,1); el.textContent = Math.floor(p*target); if (p<1) requestAnimationFrame(step); };
  requestAnimationFrame(step);
});

// Reading progress (Insights)
(function(){
  const bar = document.querySelector('.progressbar');
  if (!bar) return;
  const onScroll = () => {
    const h = document.documentElement;
    const max = h.scrollHeight - h.clientHeight;
    const pct = max ? (h.scrollTop/max)*100 : 0;
    bar.style.width = pct + '%';
  };
  document.addEventListener('scroll', onScroll, { passive:true });
  onScroll();
})();

// Sticky CTA (attention but polite)
(function(){
  const cta = document.querySelector('.sticky-cta');
  if (!cta) return;
  let shown = false;
  const onScroll = () => {
    if (shown) return;
    if (window.scrollY > 620) { cta.style.display = 'flex'; shown = true; }
  };
  cta.style.display = 'none';
  document.addEventListener('scroll', onScroll, { passive:true });
})();

// Contact form (Formspree AJAX)
const form = document.getElementById('contact-form');
if (form) {
  const status = document.getElementById('form-status');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    status.textContent = 'Sending…';
    try {
      const resp = await fetch(form.action, { method:'POST', body:new FormData(form), headers:{ 'Accept':'application/json' }});
      if (resp.ok) { status.textContent = 'Thanks — we’ll reply within 24 hours.'; form.reset(); }
      else { status.textContent = 'Could not send. Please email: contact@rbisintelligence.com'; }
    } catch { status.textContent = 'Network error. Please email: contact@rbisintelligence.com'; }
  });
}

// RBIS System demo — mini charts
(function(){
  const ctx = (sel)=>document.querySelector(sel);
  if (!ctx('#spark-cred') && !ctx('#donut-auth') && !ctx('#heat')) return;

  // Sparkline generator (SVG)
  function sparkline(el, values){
    const w=el.clientWidth||220, h=44, min=Math.min(...values), max=Math.max(...values);
    const norm = v => h - ((v-min)/(max-min||1))*(h-6) - 3;
    const step = w/(values.length-1);
    const pts = values.map((v,i)=>`${(i*step).toFixed(1)},${norm(v).toFixed(1)}`).join(' ');
    el.innerHTML = `<svg width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
      <polyline points="${pts}" fill="none" stroke="url(#g)" stroke-width="2" />
      <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#0a60ff"/><stop offset="1" stop-color="#22c55e"/></linearGradient></defs>
    </svg>`;
  }

  // Donut chart
  function donut(el, pct){ // 0-100
    const r=36, c=2*Math.PI*r, v=Math.max(0,Math.min(100,pct));
    el.innerHTML = `<svg class="donut" viewBox="0 0 100 100" width="160" height="160">
      <circle cx="50" cy="50" r="${r}" fill="none" stroke="#eef2ff" stroke-width="14"/>
      <circle cx="50" cy="50" r="${r}" fill="none" stroke="#0a60ff" stroke-width="14"
              stroke-dasharray="${(v/100)*c} ${c}" stroke-linecap="round" transform="rotate(-90 50 50)"/>
      <text x="50" y="54" text-anchor="middle" font-size="16" font-weight="800" fill="#0b0c0e">${v}%</text>
    </svg>`;
  }

  // Heatmap
  function paintHeat(){
    const cells = document.querySelectorAll('.cell[data-i]');
    cells.forEach(cell=>{
      const v = Number(cell.dataset.i);
      let bg='#dcfce7', border='#c7f0d0'; // good
      if (v>60 && v<=80){ bg='#fef3c7'; border='#fde68a'; } // warn
      if (v>80){ bg='#fee2e2'; border='#fecaca'; }         // bad
      cell.style.background = bg; cell.style.borderColor = border;
    });
  }

  // Init values
  const credVals = [72,74,73,75,77,79,80,82,83,84,84,85];
  const fraudVals = [22,21,23,21,20,19,18,18,17,17,16,16];
  sparkline(ctx('#spark-cred'), credVals);
  sparkline(ctx('#spark-fraud'), fraudVals);
  donut(ctx('#donut-auth'), 86);
  paintHeat();

  // Tabs (switches datasets)
  document.querySelectorAll('.tab').forEach(btn=>{
    btn.addEventListener('click', ()=>{
      document.querySelectorAll('.tab').forEach(b=>b.setAttribute('aria-selected','false'));
      btn.setAttribute('aria-selected','true');
      const mode = btn.dataset.mode;
      if (mode==='cred'){ sparkline(ctx('#spark-cred'), credVals); donut(ctx('#donut-auth'), 86); }
      if (mode==='fraud'){ sparkline(ctx('#spark-cred'), fraudVals); donut(ctx('#donut-auth'), 64); }
      if (mode==='access'){ donut(ctx('#donut-auth'), 92); }
    });
  });

  // Resize sparks
  let to; window.addEventListener('resize', ()=>{ clearTimeout(to); to=setTimeout(()=>{
    sparkline(ctx('#spark-cred'), credVals); sparkline(ctx('#spark-fraud'), fraudVals);
  },120);});
})();
