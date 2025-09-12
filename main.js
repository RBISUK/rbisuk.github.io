const cube = document.getElementById('cube');
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
        var _a;
        e.preventDefault();
        const target = link.getAttribute('href');
        if (target) {
            (_a = document.querySelector(target)) === null || _a === void 0 ? void 0 : _a.scrollIntoView({ behavior: 'smooth' });
        }
    });
});
