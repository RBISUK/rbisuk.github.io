function sanitizeEmailField(str){
  return (str||'').replace(/[\r\n]/g,'').replace(/[&<>"']/g,c=>'&#'+c.charCodeAt(0)+';');
}
function contactSubmit(e){
  e.preventDefault();
  const f=e.target,d=new FormData(f);
  const name=sanitizeEmailField(d.get('name')),
        email=sanitizeEmailField(d.get('email')),
        message=sanitizeEmailField(d.get('message'));
  const body='Name: '+name+'\nEmail: '+email+'\nLegal review requested: '+(d.get('legal_review')?'Yes':'No')+'\n\n'+message;
  window.location.href='mailto:Contact@RBISIntelligence.com?subject=RBIS%20Enquiry&body='+encodeURIComponent(body);
  f.reset();
  return false;
}
window.contactSubmit=contactSubmit;
