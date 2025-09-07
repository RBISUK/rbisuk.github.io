// Mobile menu toggle + current year
const burger = document.getElementById('burger');
const mobileMenu = document.getElementById('mobileMenu');
if (burger && mobileMenu) {
  burger.addEventListener('click', () => {
    const vis = mobileMenu.hasAttribute('hidden');
    mobileMenu.toggleAttribute('hidden', !vis);
    burger.setAttribute('aria-expanded', String(vis));
  });
}
const y = document.getElementById('year');
if (y) y.textContent = new Date().getFullYear();
