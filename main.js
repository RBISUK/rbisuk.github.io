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

(() => {
  const cta = document.querySelector('.sticky-cta');
  const footer = document.querySelector('.site-footer');
  if (!cta || !footer) return;
  const io = new IntersectionObserver(entries => {
    entries.forEach(e => {
      cta.style.opacity = e.isIntersecting ? '0' : '1';
    });
  });
  io.observe(footer);
})();

(() => {
  document.querySelectorAll('.stat-num[data-count]').forEach(el => {
    const target = parseInt(el.dataset.count, 10);
    el.textContent = '0';
    const io = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          let curr = 0;
          const step = target / 40;
          const tick = () => {
            curr += step;
            if (curr < target) {
              el.textContent = Math.floor(curr);
              requestAnimationFrame(tick);
            } else {
              el.textContent = target;
            }
          };
          tick();
          io.disconnect();
        }
      });
    }, { threshold: 0.6 });
    io.observe(el);
  });
})();

