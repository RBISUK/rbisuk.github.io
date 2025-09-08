// Mobile nav
const toggle = document.querySelector('.nav-toggle');
const menu = document.getElementById('primary-menu');
if (toggle && menu) {
  toggle.addEventListener('click', () => {
    const open = menu.classList.toggle('open');
    toggle.setAttribute('aria-expanded', String(open));
  });
}

// Intersection fade-in
const io = new IntersectionObserver(
  entries => entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('in'); }),
  { threshold: 0.14 }
);
document.querySelectorAll('.fade').forEach(el => io.observe(el));

// Active nav (based on body data-page)
(function setActive(){
  const page = document.body.dataset.page;
  if (!page) return;
  const link = document.querySelector(`.nav-list a[href="${page}.html"]`);
  if (link){
    link.classList.add('active');
    link.setAttribute('aria-current','page');
  }
})();

// Count-up stat
(function countUp(){
  const el = document.querySelector('.stat-num[data-count]');
  if (!el) return;
  const target = Number(el.getAttribute('data-count')) || 0;
  const start = performance.now(); const dur = 900;
  const step = t => {
    const p = Math.min((t - start)/dur,1);
    el.textContent = Math.floor(p*target);
    if (p<1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
})();

// Contact form (Formspree)
const form = document.getElementById('contact-form');
if (form) {
  const status = document.getElementById('form-status');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    status.textContent = 'Sending…';
    try {
      const resp = await fetch(form.action, {
        method: 'POST',
        body: new FormData(form),
        headers: { 'Accept': 'application/json' }
      });
      if (resp.ok) { status.textContent = 'Thanks — we’ll reply within 24 hours.'; form.reset(); }
      else { status.textContent = 'Could not send. Please email: contact@rbisintelligence.com'; }
    } catch {
      status.textContent = 'Network error. Please email: contact@rbisintelligence.com';
    }
  });
}
