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
const observer = new IntersectionObserver(
  entries => entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('in'); }),
  { threshold: 0.12 }
);
document.querySelectorAll('.fade').forEach(el => observer.observe(el));

// Count-up stat
const countEl = document.querySelector('.stat-num[data-count]');
if (countEl) {
  const target = Number(countEl.getAttribute('data-count')) || 0;
  const duration = 900;
  const start = performance.now();
  const step = now => {
    const p = Math.min((now - start) / duration, 1);
    countEl.textContent = Math.floor(p * target);
    if (p < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}

// Smooth anchor scroll (if any internal anchors later)
document.addEventListener('click', (e) => {
  const a = e.target.closest('a[href^="#"]');
  if (!a) return;
  const el = document.querySelector(a.getAttribute('href'));
  if (!el) return;
  e.preventDefault();
  el.scrollIntoView({ behavior: 'smooth', block: 'start' });
});
