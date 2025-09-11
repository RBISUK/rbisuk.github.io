function toggleEvidenceMode(){
  const on=document.getElementById('evc')?.checked;
  document.body.classList.toggle('evidence-mode',!!on);
  localStorage.setItem('rbis_evc',JSON.stringify(!!on));
}
function initEvidenceMode(){
  try{
    const st=JSON.parse(localStorage.getItem('rbis_evc')||'false');
    const evc=document.getElementById('evc');
    if(evc){
      evc.checked=!!st;
      document.body.classList.toggle('evidence-mode',!!st);
    }
  }catch{}
  const year=document.getElementById('year');
  if(year){
    year.textContent=new Date().getFullYear();
  }
}
initEvidenceMode();
window.toggleEvidenceMode=toggleEvidenceMode;
