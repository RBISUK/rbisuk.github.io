// Mobile menu toggle (accessible)
const burger = document.getElementById('burger');
const mobileMenu = document.getElementById('mobileMenu');

if (burger && mobileMenu) {
  burger.addEventListener('click', () => {
    const willOpen = mobileMenu.hasAttribute('hidden');
    mobileMenu.toggleAttribute('hidden', !willOpen);
    burger.setAttribute('aria-expanded', String(willOpen));

    // Focus the first link when opening on keyboard
    if (willOpen) {
      const firstLink = mobileMenu.querySelector('a');
      firstLink && firstLink.focus();
    }
  });
}

// Current year
const y = document.getElementById('year');
if (y) y.textContent = new Date().getFullYear();

// Reveal-on-scroll, respecting reduced motion
const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
if (!reduceMotion && 'IntersectionObserver' in window) {
  const io = new IntersectionObserver((entries) => {
    entries.forEach((e) => {
      if (e.isIntersecting) {
        e.target.classList.add('show');
        io.unobserve(e.target);
      }
    });
  }, { threshold: 0.15 });

  document.querySelectorAll('.reveal').forEach((el) => io.observe(el));
} else {
  document.querySelectorAll('.reveal').forEach((el) => el.classList.add('show'));
}

// Smooth in-page scroll (respects reduced motion)
document.querySelectorAll('a[href^="#"]').forEach((a) => {
  a.addEventListener('click', (e) => {
    const id = a.getAttribute('href') || '';
    if (id.length > 1) {
      const target = document.querySelector(id);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: reduceMotion ? 'auto' : 'smooth', block: 'start' });
      }
    }
  });
});
