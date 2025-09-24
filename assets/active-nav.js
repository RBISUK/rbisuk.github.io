(function(){
  try{
    var page=(location.pathname.split('/').pop()||'index.html').toLowerCase();
    var nav=document.querySelector('header nav'); if(!nav) return;
    nav.querySelectorAll('a').forEach(function(a){
      a.classList.remove('active'); a.removeAttribute('aria-current');
    });
    var hit=nav.querySelector('a[href="'+page+'"]') || nav.querySelector('a[href="index.html"]');
    if(hit){ hit.classList.add('active'); hit.setAttribute('aria-current','page'); }
  }catch(e){}
})();
