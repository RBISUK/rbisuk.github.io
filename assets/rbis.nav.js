(function(){
  const here = location.pathname.replace(/\/+$/,'').toLowerCase() || '/index.html';
  const items = [
    {href:'/products.html',   label:'Products'},
    {href:'/solutions.html',  label:'Solutions'},
    {href:'/websites.html',   label:'Websites'},
    {href:'/reports.html',    label:'Professional Reports'},
    {href:'/trust.html',      label:'Trust Centre'},
    {href:'/about.html',      label:'About'},
  ];
  const wrap = document.getElementById('rbis-nav');
  if(!wrap) return;

  const nav = document.createElement('nav');
  nav.className = 'rbis-nav';
  nav.innerHTML = `
    <div class="nav-inner">
      <a class="brand" href="/index.html">RBIS</a>
      <ul class="links">
        ${items.map(x=>{
          const active = here === x.href.toLowerCase();
          return `<li><a class="${active?'active':''}" href="${x.href}">${x.label}</a></li>`;
        }).join('')}
      </ul>
      <div class="cta-wrap">
        <a class="btn-cta" href="/contact.html">Contact us</a>
      </div>
    </div>`;
  wrap.replaceWith(nav);
})();
