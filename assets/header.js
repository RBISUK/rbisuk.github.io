(async () => {
  const mount = document.getElementById('site-header');
  if (!mount) return;
  const res = await fetch('assets/header.html', { cache: 'no-store' });
  mount.innerHTML = await res.text();
  const path = location.pathname.split('/').pop() || 'index.html';
  mount.querySelectorAll('nav a').forEach(a => {
    if (a.getAttribute('href') === path) a.classList.add('active');
  });
})();
