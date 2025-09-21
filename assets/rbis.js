/* RBIS base JS (progressive enhancement only) */
(() => {
  const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  document.documentElement.style.scrollBehavior = prefersReduced ? 'auto' : 'smooth';

  // Upgrade common CTAs if authors forgot classes
  document.querySelectorAll('a[href*="contact"], a[href*="#contact"]').forEach(a => {
    if (!a.classList.contains('btn')) { a.classList.add('btn','btn-secondary'); a.setAttribute('role','button'); }
  });
})();
