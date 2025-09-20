document.addEventListener('DOMContentLoaded', () => {
  const kill = (txt) => {
    document.querySelectorAll('section,div,aside,footer,a').forEach(el=>{
      if((el.textContent||'').match(new RegExp(txt,'i'))){ el.style.display='none'; }
    });
  };
  kill('Talk\\s*to\\s*RBIS');
});
