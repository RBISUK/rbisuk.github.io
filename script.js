// Mobile nav
const toggle=document.querySelector('.nav-toggle');
const menu=document.getElementById('primary-menu');
if(toggle&&menu){toggle.addEventListener('click',()=>{const open=menu.classList.toggle('open');toggle.setAttribute('aria-expanded',String(open));});}

// Fade-in on scroll
const io=new IntersectionObserver(entries=>entries.forEach(e=>{if(e.isIntersecting)e.target.classList.add('in')}),{threshold:.14});
document.querySelectorAll('.fade').forEach(el=>io.observe(el));

// Active nav
(function(){const page=document.body.dataset.page;if(!page)return;
  const link=document.querySelector(`.nav-list a[href="${page}.html"], .nav-list a[href="${page}"]`);
  if(link){link.classList.add('active');link.setAttribute('aria-current','page');}
})();

// Reading progress (for long pages)
(function(){const bar=document.querySelector('.progressbar');if(!bar)return;
  const onScroll=()=>{const h=document.documentElement;const max=h.scrollHeight-h.clientHeight;const pct=max?(h.scrollTop/max)*100:0;bar.style.width=pct+'%';};
  document.addEventListener('scroll',onScroll,{passive:true});onScroll();
})();

// ===== SMART FORM WIZARD =====
(function(){
  const form = document.getElementById('contact-form-smart');
  if(!form) return;

  // Autosave
  const KEY='rbis_contact_draft_v1';
  const saveDraft=()=>{const data=Object.fromEntries(new FormData(form)); localStorage.setItem(KEY,JSON.stringify(data));};
  const loadDraft=()=>{try{const d=JSON.parse(localStorage.getItem(KEY)||'{}'); for(const k in d){const el=form.elements[k]; if(!el) continue; if(el.type==='checkbox' || el.type==='radio'){if(Array.isArray(d[k])){[...form.elements[k]].forEach(opt=>{opt.checked=d[k].includes(opt.value);});}else{el.checked=!!d[k];}} else el.value=d[k];} }catch{}
  const clearDraft=()=>localStorage.removeItem(KEY);

  loadDraft();
  form.addEventListener('input',e=>{
    const f=e.target.closest('.field'); if(f){const inp=f.querySelector('input,textarea,select'); if(!inp) return; f.classList.toggle('filled', !!inp.value);}
    saveDraft();
  });

  // Stepper
  const steps=[...form.querySelectorAll('[data-step]')];
  const bullets=[...form.querySelectorAll('.stepper li')];
  let idx=0;

  function setStep(i){
    idx = Math.max(0, Math.min(steps.length-1, i));
    steps.forEach((s,j)=>{s.style.display = j===idx?'block':'none';});
    bullets.forEach((b,j)=>{b.classList.toggle('active', j<=idx);});
    form.scrollIntoView({behavior:'smooth', block:'start'});
  }

  setStep(0);

  // Helpers
  const q=(sel,root=document)=>root.querySelector(sel);
  const qa=(sel,root=document)=>[...root.querySelectorAll(sel)];
  function setFilledState(){qa('.field',form).forEach(f=>{const inp=q('input,textarea,select',f); if(inp) f.classList.toggle('filled', !!inp.value);});}
  setFilledState();

  // Chips (toggle)
  qa('.chip',form).forEach(chip=>{
    chip.addEventListener('click',()=>{
      chip.setAttribute('aria-pressed', chip.getAttribute('aria-pressed')!=='true');
      const target=chip.getAttribute('data-target'); if(target){const field=form.elements[target]; if(field){const v=chip.getAttribute('data-val'); const cur=field.value||''; field.value = Array.from(new Set((cur?cur.split(', '):[]).concat(chip.getAttribute('aria-pressed')==='true'?[v]:[]).filter(Boolean))).join(', ');}}
      saveDraft();
    });
  });

  // Conditional: Urgency
  const urgencySel = form.elements['urgency'];
  const urgentWrap = q('#urgent-extra',form);
  function toggleUrgent(){ if(!urgencySel||!urgentWrap) return; urgentWrap.style.display = urgencySel.value.includes('Urgent')?'block':'none'; }
  if(urgencySel){urgencySel.addEventListener('change',toggleUrgent); toggleUrgent();}

  // Validation per step
  function validateStep(i){
    const current = steps[i];
    let ok = true;
    qa('[data-required="true"] input,[data-required="true"] textarea,[data-required="true"] select', current).forEach(el=>{
      const field = el.closest('.field'); field?.classList.remove('invalid');
      if(!el.value || (el.type==='email' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(el.value))){
        field?.classList.add('invalid'); ok=false;
      }
    });
    // Extra rule: if urgent -> phone required
    if(i===1 && urgencySel && urgencySel.value.includes('Urgent')){
      const phone= form.elements['phone'];
      const wrap= phone?.closest('.field'); if(phone && (!phone.value || phone.value.replace(/\D/g,'').length<8)){wrap?.classList.add('invalid'); ok=false;}
    }
    return ok;
  }

  // Word count
  const msg = form.elements['message'];
  const wc = q('#wc');
  function updateWC(){ if(!msg||!wc) return; const n = msg.value.trim().split(/\s+/).filter(Boolean).length; wc.textContent = `${n} words`; }
  if(msg){msg.addEventListener('input',updateWC); updateWC();}

  // Build review
  function buildReview(){
    const out = q('#review-body'); if(!out) return;
    const f = Object.fromEntries(new FormData(form));
    out.innerHTML = `
      <div class="meta"><strong>Name:</strong> ${f.name||'-'} <strong>Email:</strong> ${f._replyto||'-'} <strong>Org:</strong> ${f.organisation||'-'} <strong>Role:</strong> ${f.role||'-'}</div>
      <div class="meta"><strong>Subject:</strong> ${f.subject||'-'} <strong>Urgency:</strong> ${f.urgency||'-'} <strong>Preferred Contact:</strong> ${f.pref_contact||'-'}</div>
      <div class="meta"><strong>Topics:</strong> ${f.topics||'-'}</div>
      <div class="kitem"><strong>Message</strong><div class="small muted">${(f.message||'').replace(/</g,'&lt;')}</div></div>
      <div class="meta"><strong>NDA Required:</strong> ${f.nda==='on'?'Yes':'No'} <strong>Secure Upload:</strong> ${f.secure==='on'?'Yes':'No'}</div>
    `;
  }

  // Navigation
  q('#next1')?.addEventListener('click',()=>{ if(validateStep(0)){ setStep(1);} });
  q('#back2')?.addEventListener('click',()=>setStep(0));
  q('#next2')?.addEventListener('click',()=>{ if(validateStep(1)){ setStep(2);} });
  q('#back3')?.addEventListener('click',()=>setStep(1));
  q('#next3')?.addEventListener('click',()=>{ if(validateStep(2)){ buildReview(); setStep(3);} });
  q('#back4')?.addEventListener('click',()=>setStep(2));

  // Time-to-complete (anti-bot telemetry)
  const startTs = Date.now(); form.elements['ttc'].value = startTs.toString();

  // Submit (Formspree)
  const status = document.getElementById('form-status');
  form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    status.textContent='Sending…';
    const submitBtn = form.querySelector('button[type="submit"]'); submitBtn?.setAttribute('disabled','true');

    try{
      const fd = new FormData(form);
      // add computed ttc seconds
      fd.set('ttc_seconds', Math.round((Date.now()-startTs)/1000));
      const resp = await fetch(form.action, { method:'POST', body: fd, headers:{'Accept':'application/json'}});
      if(resp.ok){
        status.textContent='Thanks — we’ll reply within 24 hours.';
        clearDraft();
        setTimeout(()=>{ window.location.href = 'thank-you.html';}, 500);
      }else{
        status.textContent='Could not send. Please email: contact@rbisintelligence.com';
        submitBtn?.removeAttribute('disabled');
      }
    }catch(err){
      status.textContent='Network error. Please email: contact@rbisintelligence.com';
      submitBtn?.removeAttribute('disabled');
    }
  });

  // Pre-fill subject from topic chips
  qa('[data-fill-subject]').forEach(btn=>{
    btn.addEventListener('click',()=>{
      const s=form.elements['subject']; if(s && !s.value){ s.value = btn.getAttribute('data-fill-subject')||''; s.dispatchEvent(new Event('input')); }
    });
  });

  // Enforce filled class on load
  qa('.field input,.field textarea,.field select',form).forEach(el=>{
    const f=el.closest('.field'); if(f) f.classList.toggle('filled', !!el.value);
  });

})();