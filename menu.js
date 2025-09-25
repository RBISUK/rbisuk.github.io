(function(){var d=document,b=d.body,h=d.querySelector('#site-header')||d.querySelector('header');if(!h)return;var n=h.querySelector('nav[aria-label="Primary"]')||h.querySelector('nav');if(!n)return;var w=h.querySelector('.nav-drawer');if(!w){w=d.createElement('div');w.className='nav-drawer';w.id='nav-drawer';n.parentNode.insertBefore(w,n);w.appendChild(n);}var k=d.querySelector('.backdrop');if(!k){k=d.createElement('div');k.className='backdrop';b.appendChild(k);}var t=h.querySelector('.nav-toggle');if(!t){t=d.createElement('button');t.className='nav-toggle';t.type='button';t.setAttribute('aria-label','Menu');t.setAttribute('aria-controls','nav-drawer');t.setAttribute('aria-expanded','false');t.innerHTML='<span class="bars" aria-hidden="true"><span class="bar"></span></span>';h.appendChild(t);}function open(){b.classList.add('nav-open');t.setAttribute('aria-expanded','true');w.setAttribute('data-open','');k.setAttribute('data-open','');h.classList.remove('hide');}function close(){b.classList.remove('nav-open');t.setAttribute('aria-expanded','false');w.removeAttribute('data-open');k.removeAttribute('data-open');}t.addEventListener('click',function(){b.classList.contains('nav-open')?close():open()});k.addEventListener('click',close);d.addEventListener('keydown',function(e){if(e.key==='Escape')close()},{passive:true});w.addEventListener('click',function(e){var a=e.target.closest('a');if(a&&b.classList.contains('nav-open'))setTimeout(close,120)});window.addEventListener('resize',function(){if(matchMedia('(min-width:900px)').matches)close()});document.addEventListener('scroll',function(){if(b.classList.contains('nav-open'))h.classList.remove('hide')},{passive:true});})();(function(){var d=document,b=d.body,h=d.querySelector('#site-header')||d.querySelector('header');if(!h)return;var y=pageYOffset,l=performance.now();addEventListener('scroll',function(){if(b.classList.contains('nav-open')){h.classList.remove('hide');y=pageYOffset;l=performance.now();return}var Y=pageYOffset,t=performance.now(),dy=Y-y,dt=t-l,v=Math.abs(dy)/Math.max(1,dt);if(Y<=8||innerHeight+Y>=d.documentElement.scrollHeight-1)h.classList.remove('hide');else if(dy>0&&Y>140&&v>.6)h.classList.add('hide');else if(dy<0&&(Math.abs(dy)>12||v>.1))h.classList.remove('hide');y=Y;l=t},{passive:true});})();
(function(){var d=document,b=d.body,h=d.querySelector("#site-header")||d.querySelector("header");if(!h)return;var y=pageYOffset,t=performance.now();addEventListener("scroll",function(){if(b.classList.contains("nav-open")){h.classList.remove("hide");y=pageYOffset;t=performance.now();return}var Y=pageYOffset,T=performance.now(),dy=Y-y,dt=Math.max(1,T-t),v=Math.abs(dy)/dt;if(Y<=8||innerHeight+Y>=d.documentElement.scrollHeight-1)h.classList.remove("hide");else if(dy>0&&Y>140&&v>.6)h.classList.add("hide");else if(dy<0&&(Math.abs(dy)>12||v>.1))h.classList.remove("hide");y=Y;t=T},{passive:true});})();
(function(){
  var q=function(s){return document.querySelector(s)};
  var nav = q('#site-header nav') || q('header nav'); if(!nav) return;
  // remove bare text nodes (e.g., "Products", "Company" headings that leaked as text)
  var strip=function(root){
    Array.prototype.slice.call(root.childNodes).forEach(function(n){
      if(n.nodeType===3 && n.textContent.trim()) n.remove();
      else if(n.nodeType===1) strip(n);
    });
  };
  strip(nav);
})();
(function(){
  var d=document;
  function strip(root){
    Array.prototype.slice.call(root.childNodes).forEach(function(n){
      if(n.nodeType===3 && n.textContent.trim()) n.remove();
      else if(n.nodeType===1) strip(n);
    });
  }
  var dn=d.querySelector('.nav-drawer nav'); if(dn) strip(dn);
})();
