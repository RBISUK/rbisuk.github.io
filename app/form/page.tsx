"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
function isUKMobile(s:string){ return /^(?:\+44|0)7\d{9}$/.test(s||""); }
function isEmail(s:string){ return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s||""); }

export default function FormPage(){
  const router = useRouter();
  const [step,setStep]=useState(1);
  const [client,setClient]=useState({title:"",firstName:"",middleName:"",lastName:"",mobile:"",email:""});
  const [issue,setIssue]=useState({type:"",duration:"",description:""});
  const [upsell,setUpsell]=useState({debts:false,badCredit:false,pcp:false,payday:false,pii:false});
  const [website,setWebsite]=useState(""); // honeypot
  const [busy,setBusy]=useState(false); const [err,setErr]=useState<string|null>(null);
  const total=4; const pct=Math.round((step/total)*100);
  async function submit(){
    setBusy(true); setErr(null);
    try{
      const r=await fetch("/api/submit",{method:"POST",headers:{"content-type":"application/json"},
        body: JSON.stringify({product:"Housing Disrepair",client,issue,upsell,website})});
      if(!r.ok){ const j=await r.json().catch(()=>({})); throw new Error(j.error||"Submit failed"); }
      router.push("/thank-you");
    }catch(e:any){ setErr(e.message||"Error"); } finally{ setBusy(false); }
  }
  return (
    <div className="container py-10">
      <div className="mb-6">
        <div className="flex justify-between text-sm text-gray-400"><span>Step {step} of {total}</span><span>{pct}%</span></div>
        <div className="h-2 bg-white/10 rounded"><div className="h-2 bg-blue-600 rounded" style={{width:`${pct}%`}}/></div>
      </div>

      {step===1 && (<section className="grid sm:grid-cols-2 gap-4">
        <h2 className="sm:col-span-2 text-xl font-semibold">Your details</h2>
        <label className="block">Title
          <select className="mt-1 w-full rounded border border-white/10 bg-white/5 p-2" value={client.title}
            onChange={e=>setClient({...client,title:e.target.value})}>
            <option value="">Select…</option><option>Mr</option><option>Ms</option><option>Mrs</option><option>Mx</option><option>Dr</option>
          </select>
        </label>
        <label className="block">First name
          <input className="mt-1 w-full rounded border border-white/10 bg-white/5 p-2" value={client.firstName}
            onChange={e=>setClient({...client,firstName:e.target.value})}/>
        </label>
        <label className="block">Middle name (optional)
          <input className="mt-1 w-full rounded border border-white/10 bg-white/5 p-2" value={client.middleName}
            onChange={e=>setClient({...client,middleName:e.target.value})}/>
        </label>
        <label className="block">Last name
          <input className="mt-1 w-full rounded border border-white/10 bg-white/5 p-2" value={client.lastName}
            onChange={e=>setClient({...client,lastName:e.target.value})}/>
        </label>
        <label className="block">Mobile (UK)
          <input className="mt-1 w-full rounded border border-white/10 bg-white/5 p-2" placeholder="07xxxxxxxxx" value={client.mobile}
            onChange={e=>setClient({...client,mobile:e.target.value})}/>
          {client.mobile && !isUKMobile(client.mobile) && <p className="text-xs text-red-400 mt-1">Enter a valid UK mobile.</p>}
        </label>
        <label className="block">Email
          <input className="mt-1 w-full rounded border border-white/10 bg-white/5 p-2" placeholder="you@example.com" value={client.email}
            onChange={e=>setClient({...client,email:e.target.value})}/>
          {client.email && !isEmail(client.email) && <p className="text-xs text-red-400 mt-1">Enter a valid email.</p>}
        </label>
        <input className="hidden" value={website} onChange={e=>setWebsite(e.target.value)} />
        <div className="sm:col-span-2 mt-4"><button onClick={()=>setStep(2)} className="btn btn-primary">Continue</button></div>
      </section>)}

      {step===2 && (<section className="grid sm:grid-cols-2 gap-4">
        <h2 className="sm:col-span-2 text-xl font-semibold">Housing issue</h2>
        <label className="block">Main problem
          <select className="mt-1 w-full rounded border border-white/10 bg-white/5 p-2" value={issue.type}
            onChange={e=>setIssue({...issue,type:e.target.value})}>
            <option value="">Select…</option>
            <option>Damp/Mould</option><option>Leaks</option><option>Heating</option>
            <option>Electrics</option><option>Pests</option><option>Structural</option><option>Other</option>
          </select>
        </label>
        <label className="block">Duration
          <input className="mt-1 w-full rounded border border-white/10 bg-white/5 p-2" placeholder="e.g., 6 months"
            value={issue.duration} onChange={e=>setIssue({...issue,duration:e.target.value})}/>
        </label>
        <label className="block sm:col-span-2">Brief description
          <textarea className="mt-1 w-full rounded border border-white/10 bg-white/5 p-2" rows={4}
            value={issue.description} onChange={e=>setIssue({...issue,description:e.target.value})}
            placeholder="Tell us how this affects you (health, belongings, rooms unusable)…"/>
        </label>
        <div className="sm:col-span-2 mt-2 flex gap-3">
          <button onClick={()=>setStep(1)} className="btn btn-ghost">Back</button>
          <button onClick={()=>setStep(3)} className="btn btn-primary">Continue</button>
        </div>
      </section>)}

      {step===3 && (<section>
        <h2 className="text-xl font-semibold">Other help (optional)</h2>
        <p className="text-gray-400 mt-1">Tick any that apply — it helps us prioritise support.</p>
        <div className="mt-3 grid sm:grid-cols-2 gap-2">
          <label><input type="checkbox" checked={upsell.debts} onChange={e=>setUpsell({...upsell,debts:e.target.checked})}/> Debts / IVA / DMP</label>
          <label><input type="checkbox" checked={upsell.badCredit} onChange={e=>setUpsell({...upsell,badCredit:e.target.checked})}/> Bad credit / CCJs</label>
          <label><input type="checkbox" checked={upsell.pcp} onChange={e=>setUpsell({...upsell,pcp:e.target.checked})}/> PCP / Car finance issues</label>
          <label><input type="checkbox" checked={upsell.payday} onChange={e=>setUpsell({...upsell,payday:e.target.checked})}/> Payday / high-cost loans</label>
          <label><input type="checkbox" checked={upsell.pii} onChange={e=>setUpsell({...upsell,pii:e.target.checked})}/> Personal injury</label>
        </div>
        <div className="mt-4 flex gap-3">
          <button onClick={()=>setStep(2)} className="btn btn-ghost">Back</button>
          <button onClick={()=>setStep(4)} className="btn btn-primary">Continue</button>
        </div>
      </section>)}

      {step===4 && (<section>
        <h2 className="text-xl font-semibold">Submit</h2>
        <p className="text-gray-400 mt-2 text-sm">
          By submitting, you consent to us contacting you about your enquiry and processing your data per our Privacy Policy.
        </p>
        {err && <p className="mt-3 text-red-400">{err}</p>}
        <div className="mt-4 flex gap-3">
          <button onClick={()=>setStep(3)} className="btn btn-ghost">Back</button>
          <button onClick={submit} disabled={busy} className="btn btn-primary">{busy?"Sending…":"Submit"}</button>
        </div>
      </section>)}
    </div>
  );
}
