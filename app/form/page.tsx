"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";

type Client = { title:string; firstName:string; middleName?:string; lastName:string; mobile:string; email:string; };
type Issue = { type:string; duration:string; description?:string; };
type Upsell = { debts?:boolean; badCredit?:boolean; pcp?:boolean; payday?:boolean; pii?:boolean; };

const okEmail = (e:string)=>/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e||"");
const okUkMob = (m:string)=>/^(?:\+44|0)7\d{9}$/.test(m||"");

export default function FormPage(){
  const [step,setStep]=useState(1);
  const [client,setClient]=useState<Client>({title:"",firstName:"",middleName:"",lastName:"",mobile:"",email:""});
  const [issue,setIssue]=useState<Issue>({type:"",duration:"",description:""});
  const [upsell,setUpsell]=useState<Upsell>({});
  const [website,setWebsite]=useState(""); // honeypot
  const [err,setErr]=useState<string|null>(null);
  const [busy,setBusy]=useState(false);
  const router=useRouter();

  async function submit(){
    setBusy(true); setErr(null);
    try{
      const r=await fetch("/api/submit",{method:"POST",headers:{"content-type":"application/json"},
        body:JSON.stringify({product:"Housing Disrepair",client,issue,upsell,website})});
      if(!r.ok){ const j=await r.json().catch(()=>({})); throw new Error(j.error||`HTTP ${r.status}`); }
      router.push("/thank-you");
    }catch(e:any){ setErr(e.message||"Submit failed"); } finally{ setBusy(false); }
  }

  return (
    <main className="max-w-3xl mx-auto p-6">
      {step===1 && (
        <section>
          <h2 className="text-xl font-semibold">Your details</h2>
          <div className="grid sm:grid-cols-2 gap-3 mt-4">
            <label>Title
              <select className="mt-1 w-full border rounded p-2" value={client.title}
                onChange={e=>setClient({...client,title:e.target.value})}>
                <option value="">Select…</option><option>Mr</option><option>Ms</option><option>Mrs</option><option>Mx</option><option>Dr</option>
              </select>
            </label>
            <label>First name
              <input className="mt-1 w-full border rounded p-2" value={client.firstName}
                onChange={e=>setClient({...client,firstName:e.target.value})}/>
            </label>
            <label>Middle name (optional)
              <input className="mt-1 w-full border rounded p-2" value={client.middleName}
                onChange={e=>setClient({...client,middleName:e.target.value})}/>
            </label>
            <label>Last name
              <input className="mt-1 w-full border rounded p-2" value={client.lastName}
                onChange={e=>setClient({...client,lastName:e.target.value})}/>
            </label>
            <label>Mobile (UK)
              <input className="mt-1 w-full border rounded p-2" placeholder="07xxxxxxxxx" value={client.mobile}
                onChange={e=>setClient({...client,mobile:e.target.value})}/>
              {client.mobile && !okUkMob(client.mobile) && <p className="text-red-600 text-xs">Enter a valid UK mobile.</p>}
            </label>
            <label>Email
              <input className="mt-1 w-full border rounded p-2" placeholder="you@example.com" value={client.email}
                onChange={e=>setClient({...client,email:e.target.value})}/>
              {client.email && !okEmail(client.email) && <p className="text-red-600 text-xs">Enter a valid email.</p>}
            </label>
          </div>
          <input className="hidden" value={website} onChange={e=>setWebsite(e.target.value)} />
          <button onClick={()=>setStep(2)} className="mt-6 px-4 py-2 rounded bg-blue-600 text-white">Continue</button>
        </section>
      )}

      {step===2 && (
        <section>
          <h2 className="text-xl font-semibold">Housing issue</h2>
          <div className="grid sm:grid-cols-2 gap-3 mt-4">
            <label>Main problem
              <select className="mt-1 w-full border rounded p-2" value={issue.type}
                onChange={e=>setIssue({...issue,type:e.target.value})}>
                <option value="">Select…</option>
                <option>Damp/Mould</option><option>Leaks</option><option>Heating</option>
                <option>Electrics</option><option>Pests</option><option>Structural</option><option>Other</option>
              </select>
            </label>
            <label>How long
              <input className="mt-1 w-full border rounded p-2" placeholder="e.g., 6 months" value={issue.duration}
                onChange={e=>setIssue({...issue,duration:e.target.value})}/>
            </label>
            <label className="sm:col-span-2">Brief description
              <textarea className="mt-1 w-full border rounded p-2" rows={4} value={issue.description}
                onChange={e=>setIssue({...issue,description:e.target.value})}/>
            </label>
          </div>
          <div className="mt-6 flex gap-3">
            <button onClick={()=>setStep(1)} className="px-4 py-2 rounded border">Back</button>
            <button onClick={()=>setStep(3)} className="px-4 py-2 rounded bg-blue-600 text-white">Continue</button>
          </div>
        </section>
      )}

      {step===3 && (
        <section>
          <h2 className="text-xl font-semibold">Other help (optional)</h2>
          <div className="grid sm:grid-cols-2 gap-2 mt-3">
            <label><input type="checkbox" checked={!!upsell.debts} onChange={e=>setUpsell({...upsell,debts:e.target.checked})}/> Debts / IVA / DMP</label>
            <label><input type="checkbox" checked={!!upsell.badCredit} onChange={e=>setUpsell({...upsell,badCredit:e.target.checked})}/> Bad credit / CCJs</label>
            <label><input type="checkbox" checked={!!upsell.pcp} onChange={e=>setUpsell({...upsell,pcp:e.target.checked})}/> PCP / Car finance</label>
            <label><input type="checkbox" checked={!!upsell.payday} onChange={e=>setUpsell({...upsell,payday:e.target.checked})}/> Payday loans</label>
            <label><input type="checkbox" checked={!!upsell.pii} onChange={e=>setUpsell({...upsell,pii:e.target.checked})}/> Personal injury</label>
          </div>
          <div className="mt-6 flex gap-3">
            <button onClick={()=>setStep(2)} className="px-4 py-2 rounded border">Back</button>
            <button onClick={()=>setStep(4)} className="px-4 py-2 rounded bg-blue-600 text-white">Continue</button>
          </div>
        </section>
      )}

      {step===4 && (
        <section>
          <h2 className="text-xl font-semibold">Submit</h2>
          {err && <p className="text-red-600 text-sm">{err}</p>}
          <div className="mt-6 flex gap-3">
            <button onClick={()=>setStep(3)} className="px-4 py-2 rounded border">Back</button>
            <button onClick={submit} disabled={busy} className="px-4 py-2 rounded bg-green-600 text-white">
              {busy ? "Sending…" : "Submit"}
            </button>
          </div>
        </section>
      )}
    </main>
  );
}
