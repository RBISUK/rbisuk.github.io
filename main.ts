const cube = document.getElementById('cube') as HTMLElement;
let rotateX = 0;
let rotateY = 0;

function animate() {
  rotateX += 0.01;
  rotateY += 0.01;
  cube.style.transform = `rotateX(${rotateX}rad) rotateY(${rotateY}rad)`;
  requestAnimationFrame(animate);
}

if (cube) {
  animate();
}

// smooth scrolling for navigation links
document.querySelectorAll('nav a').forEach(link => {
  link.addEventListener('click', e => {
    e.preventDefault();
    const target = (link as HTMLAnchorElement).getAttribute('href');
    if (target) {
      document.querySelector(target)?.scrollIntoView({ behavior: 'smooth' });
    }
  });
});
