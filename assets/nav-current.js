(()=>{try{
  const norm=p=>(p||"/").replace(/index\.html?$/,"").replace(/\/+$/,"/")||"/";
  const here=norm(location.pathname);
  document.querySelectorAll('nav a[href]').forEach(a=>{
    const href=norm(a.getAttribute('href')||'');
    if(href===here || href.replace(/\/$/,'')===here.replace(/\/$/,'')){
      a.setAttribute('aria-current','page');
    }
  });
}catch(e){}})();
