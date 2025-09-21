document.addEventListener('DOMContentLoaded', () => {
  const kill = (txt) => {
    document.querySelectorAll('section,div,aside,footer,a').forEach(el=>{
      if((el.textContent||'').match(new RegExp(txt,'i'))){ el.style.display='none'; }
    });
  };
  kill('Talk\\s*to\\s*RBIS');
});
/* RBIS hero parallax */
(() => {
  let ticking=false, p=0;
  const setP = () => {
    const y = window.scrollY||0;
    p = Math.max(0, Math.min(1, y/600)); // 0..1 over first ~600px
    document.documentElement.style.setProperty('--p', String(p));
    ticking=false;
  };
  window.addEventListener('scroll', () => { if(!ticking){ requestAnimationFrame(setP); ticking=true; } }, {passive:true});
  setP();
})();
/* RBIS hero parallax v2 */
(() => {
  let ticking=false;
  const rafUpdate = () => {
    const y = window.scrollY||0;
    const p = Math.max(0, Math.min(1, y/600)); // clamp 0..1
    document.documentElement.style.setProperty('--p', String(p));
    ticking=false;
  };
  window.addEventListener('scroll', () => {
    if(!ticking){ requestAnimationFrame(rafUpdate); ticking=true; }
  }, {passive:true});
  rafUpdate();
})();
/* RBIS hero parallax v3 */
(()=>{let t=!1;const n=()=>{const e=window.scrollY||0;document.documentElement.style.setProperty("--p",String(Math.max(0,Math.min(1,e/600)))),t=!1};window.addEventListener("scroll",()=>{t||(requestAnimationFrame(n),t=!0)},{passive:!0});n()})();
