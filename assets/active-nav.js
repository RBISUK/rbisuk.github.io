(function(){
  try{
    var page=(location.pathname.split('/').pop()||'index.html').toLowerCase();
    var nav=document.querySelector('header nav'); if(!nav) return;
    nav.querySelectorAll('a').forEach(function(a){
      a.classList.remove('active'); a.removeAttribute('aria-current');
      var href=(a.getAttribute('href')||'').toLowerCase();
      if(href===page){ a.classList.add('active'); a.setAttribute('aria-current','page'); }
    });
    // default Home if nothing matches
    if(!nav.querySelector('a.active')){
      var home=nav.querySelector('a[href="index.html"]'); if(home){home.classList.add('active'); home.setAttribute('aria-current','page');}
    }
  }catch(e){}
})();
