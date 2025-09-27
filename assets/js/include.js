(function(){
  const nodes = document.querySelectorAll('[data-include]');
  nodes.forEach(async (el)=>{
    const src = el.getAttribute('data-include');
    try{
      const res = await fetch(src, {credentials:'same-origin', cache:'no-store'});
      if(!res.ok) throw new Error(src+' '+res.status);
      el.outerHTML = await res.text();
    }catch(e){ console.warn('Include failed:', e); }
  });
})();
