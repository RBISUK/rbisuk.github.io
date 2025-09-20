(function(){
  const nav = document.querySelector('.nav');
  const toggle = document.getElementById('nav-toggle');
  if (toggle) toggle.addEventListener('click', ()=> nav.classList.toggle('open'));
  // active link
  const here = location.pathname.toLowerCase();
  document.querySelectorAll('.nav a.link').forEach(a=>{
    const href = a.getAttribute('href')||'';
    if (href && here.endsWith(href.toLowerCase())) a.classList.add('active');
  });
})();
