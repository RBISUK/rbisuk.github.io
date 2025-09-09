'use strict';

(() => {
  const toggle = document.querySelector('.nav-toggle');
  const menu = document.getElementById('primary-menu');
  if (toggle && menu) {
    toggle.addEventListener('click', () => {
      const open = menu.classList.toggle('open');
      toggle.setAttribute('aria-expanded', String(open));
    });
  }
})();

(() => {
  const io = new IntersectionObserver(entries =>
    entries.forEach(e => {
      if (e.isIntersecting) e.target.classList.add('in');
    }),
    { threshold: 0.14 }
  );
  document.querySelectorAll('.fade').forEach(el => io.observe(el));
})();

(() => {
  const page = document.body.dataset.page;
  if (!page) return;
  const link = document.querySelector(
    `.nav-list a[href="${page}.html"], .nav-list a[href="${page}"]`
  );
  if (link) {
    link.classList.add('active');
    link.setAttribute('aria-current', 'page');
  }
})();

(() => {
  const bar = document.querySelector('.progressbar');
  if (!bar) return;
  const onScroll = () => {
    const h = document.documentElement;
    const max = h.scrollHeight - h.clientHeight;
    const pct = max ? (h.scrollTop / max) * 100 : 0;
    bar.style.width = pct + '%';
  };
  document.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
})();

