(function(){
  function ready(fn){ document.readyState==='loading'?document.addEventListener('DOMContentLoaded',fn):fn(); }
  ready(function(){
    const toggle=document.querySelector('[data-nav-toggle]');
    let drawer=document.getElementById('navdrawer');
    if(!drawer){ drawer=document.createElement('div'); drawer.id='navdrawer'; drawer.hidden=true; document.body.appendChild(drawer); }
    drawer.innerHTML = '<div class="nav-drawer__panel" role="dialog" aria-modal="true" aria-label="Mobile menu"><button class="nav-close" data-nav-close aria-label="Close menu">✕</button><nav class="nav-mobile" aria-label="Mobile Primary"><a href="/claim-fix-ai.html">Claim-Fix-AI</a><a href="/copilot.html">OmniAssist</a><a href="/nextusone.html">NextusOne CRM</a><a href="/dashboard.html">Dashboard</a><a href="/solutions-housing.html">Solutions</a><a href="/about.html">About</a><a href="/careers.html">Careers</a><a class="btn" href="/contact.html#contact-form">Request Demo</a></nav><div class="nav-drawer__footer"><p class="notice">Independent intelligence analysis and reporting. Not a law firm.</p><a class="hush" href="mailto:contact@rbisintelligence.com">contact@rbisintelligence.com</a></div></div>';
    const panel=drawer.querySelector('.nav-drawer__panel'); const closers=drawer.querySelectorAll('[data-nav-close]');
    const focusable='a[href],button:not([disabled]),[tabindex]:not([tabindex="-1"]),input,select,textarea'; let last=null, sy=0;
    function lock(){ sy=window.scrollY; document.body.style.top=`-${sy}px`; document.body.classList.add('body-locked'); }
    function unlock(){ document.body.classList.remove('body-locked'); document.body.style.top=''; window.scrollTo(0,sy); }
    function open(){ if(drawer.hasAttribute('data-open')) return; last=document.activeElement; drawer.hidden=false; drawer.setAttribute('data-open',''); toggle&&toggle.setAttribute('aria-expanded','true'); lock(); panel.querySelector(focusable)?.focus(); document.addEventListener('keydown',trap,true); document.addEventListener('keydown',esc,true); }
    function close(){ if(!drawer.hasAttribute('data-open')) return; drawer.removeAttribute('data-open'); toggle&&toggle.setAttribute('aria-expanded','false'); unlock(); document.removeEventListener('keydown',trap,true); document.removeEventListener('keydown',esc,true); setTimeout(()=>{drawer.hidden=true;},180); last&&last.focus&&last.focus(); }
    function esc(e){ if(e.key==='Escape') close(); }
    function trap(e){ if(e.key!=='Tab') return; const nodes=panel.querySelectorAll(focusable); if(!nodes.length) return; const first=nodes[0], last=nodes[nodes.length-1]; if(e.shiftKey&&document.activeElement===first){ last.focus(); e.preventDefault(); } else if(!e.shiftKey&&document.activeElement===last){ first.focus(); e.preventDefault(); } }
    toggle&&toggle.addEventListener('click',open,{passive:true}); closers.forEach(c=>c.addEventListener('click',close,{passive:true}));
    window.addEventListener('pageshow',(e)=>{ if(e.persisted){ document.body.classList.remove('body-locked'); document.body.style.top=''; }},{passive:true});
  });
})();
