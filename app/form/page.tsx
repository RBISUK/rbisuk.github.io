"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";

type FormData = {
  title: string;
  firstName: string;
  middleName?: string;
  lastName: string;
  mobile: string;
  email: string;
  claimType: "HDR";
  tenancyType: "Council" | "Housing Association" | "Private" | "Other";
  region: "England" | "Wales" | "Other";
  issueMain: string;
  issueDuration: string;
  cross: {
    debtsOrIVA: boolean;
    badCredit: boolean;
    pcp: boolean;
    payday: boolean;
    misSold: boolean;
  };
};

function initialData(): FormData {
  return {
    title: "Mr",
    firstName: "",
    middleName: "",
    lastName: "",
    mobile: "",
    email: "",
    claimType: "HDR",
    tenancyType: "Council",
    region: "England",
    issueMain: "Damp/Mould",
    issueDuration: "",
    cross: { debtsOrIVA:false, badCredit:false, pcp:false, payday:false, misSold:false },
  };
}

export default function HousingIntake() {
  const [startedAt] = useState<number>(() => Date.now());

  const router = useRouter();
  const [step, setStep] = useState(1);
  const totalSteps = 5;
  const [data, setData] = useState<FormData>(initialData());
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const next = () => setStep(s => Math.min(s+1, totalSteps));
  const back = () => setStep(s => Math.max(s-1, 1));

  async function submit() {
    setErr(null);
    setBusy(true);
    try {
      const res = await fetch("/api/submit", {
        method: "POST",
        headers: { "Content-Type":"application/json" },
        body: JSON.stringify({ ...data, startedAt, hp: "" }),
      });
      const j = await res.json();
      if (!res.ok || !j.ok) throw new Error(j.error || `HTTP ${res.status}`);
      router.push("/thank-you");
    } catch (e:any) {
      setErr(e?.message || "Submission failed");
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="min-h-[60vh] p-6 max-w-3xl mx-auto">
      <Progress step={step} total={totalSteps} />
      {step === 1 && <StepClientDetails data={data} setData={setData} onNext={next} />}
      {step === 2 && <StepEligibility data={data} setData={setData} onNext={next} onBack={back} />}
      {step === 3 && <StepHdrDetails data={data} setData={setData} onNext={next} onBack={back} />}
      {step === 4 && <StepCrossSell data={data} setData={setData} onNext={next} onBack={back} />}
      {step === 5 && <StepSubmit data={data} onBack={back} onSubmit={submit} busy={busy} err={err} />}
      <p className="mt-4 text-sm text-gray-600 bg-gray-50 border rounded p-3">
        We comply with GDPR, never sell your data, and your form is reviewed by a trained human — not AI.
        Your rights are protected by law.
      </p>
    </main>
  );
}

function Progress({ step, total }: { step: number; total: number }) {
  const pct = Math.round((step / total) * 100);
  return (
    <div className="mb-6">
      <div className="flex justify-between text-sm text-gray-500">
        <span>Step {step} of {total}</span><span>{pct}%</span>
      </div>
      <div className="w-full h-2 bg-gray-200 rounded">
        <div className="h-2 bg-blue-600 rounded" style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

function StepClientDetails({ data, setData, onNext }:{
  data: FormData; setData: (u: any) => void; onNext: () => void;
}) {
  const [localErr, setLocalErr] = useState<string | null>(null);
  function proceed() {
    setLocalErr(null);
    if (!data.firstName.trim() || !data.lastName.trim()) return setLocalErr("Please enter your name.");
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) return setLocalErr("Please enter a valid email.");
    if (!/^(07\d{9}|(\+447|00447)\d{9})$/.test(data.mobile.replace(/[^\d+]/g,""))) return setLocalErr("Please enter a valid UK mobile (07..., +447...).");
    onNext();
  }
  return (
    <section>
      <h2 className="text-2xl font-semibold">Your details</h2>
      <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-3">
        <label className="block">Title
          <select className="mt-1 block w-full border rounded-lg p-2"
            value={data.title}
            onChange={e=>setData((d:FormData)=>({...d, title: e.target.value as any}))}>
            <option>Mr</option><option>Mrs</option><option>Miss</option><option>Ms</option><option>Dr</option>
          </select>
        </label>
        <label className="block">First name
          <input className="mt-1 block w-full border rounded-lg p-2"
            value={data.firstName}
            onChange={e=>setData((d:FormData)=>({...d, firstName:e.target.value}))}/>
        </label>
        <label className="block">Middle name (optional)
          <input className="mt-1 block w-full border rounded-lg p-2"
            value={data.middleName || ""}
            onChange={e=>setData((d:FormData)=>({...d, middleName:e.target.value}))}/>
        </label>
        <label className="block">Last name
          <input className="mt-1 block w-full border rounded-lg p-2"
            value={data.lastName}
            onChange={e=>setData((d:FormData)=>({...d, lastName:e.target.value}))}/>
        </label>
        <label className="block">Mobile number
          <input type="tel" className="mt-1 block w-full border rounded-lg p-2" placeholder="07..."
            value={data.mobile}
            onChange={e=>setData((d:FormData)=>({...d, mobile:e.target.value}))}/>
        </label>
        <label className="block">Email
          <input type="email" className="mt-1 block w-full border rounded-lg p-2" placeholder="name@example.com"
            value={data.email}
            onChange={e=>setData((d:FormData)=>({...d, email:e.target.value}))}/>
        </label>
      </div>
      {localErr && <p className="text-red-600 mt-2">{localErr}</p>}
      <div className="mt-6 flex gap-3">
        <button onClick={proceed} className="px-4 py-2 rounded-lg bg-blue-600 text-white">Continue</button>
      </div>
    
      <input type="text" name="hp" autoComplete="off" tabIndex="-1" className="hidden" onChange={() => {}} />
    </section>
  );
}

function StepEligibility({ data, setData, onNext, onBack }:{
  data: FormData; setData: (u:any)=>void; onNext:()=>void; onBack:()=>void;
}) {
  return (
    <section>
      <h2 className="text-2xl font-semibold">Quick eligibility</h2>
      <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-3">
        <label className="block">Region
          <select className="mt-1 block w-full border rounded-lg p-2"
            value={data.region}
            onChange={e=>setData((d:FormData)=>({...d, region: e.target.value as any}))}>
            <option>England</option><option>Wales</option><option>Other</option>
          </select>
        </label>
        <label className="block">Tenancy type
          <select className="mt-1 block w-full border rounded-lg p-2"
            value={data.tenancyType}
            onChange={e=>setData((d:FormData)=>({...d, tenancyType: e.target.value as any}))}>
            <option>Council</option><option>Housing Association</option><option>Private</option><option>Other</option>
          </select>
        </label>
      </div>
      <div className="mt-6 flex gap-3">
        <button onClick={onBack} className="px-4 py-2 rounded-lg border">Back</button>
        <button onClick={onNext} className="px-4 py-2 rounded-lg bg-blue-600 text-white">Continue</button>
      </div>
    
      <input type="text" name="hp" autoComplete="off" tabIndex="-1" className="hidden" onChange={() => {}} />
    </section>
  );
}

function StepHdrDetails({ data, setData, onNext, onBack }:{
  data: FormData; setData:(u:any)=>void; onNext:()=>void; onBack:()=>void;
}) {
  return (
    <section>
      <h2 className="text-2xl font-semibold">Housing disrepair details</h2>
      <div className="mt-4 space-y-3">
        <label className="block">Main problem
          <select className="mt-1 block w-full border rounded-lg p-2"
            value={data.issueMain}
            onChange={e=>setData((d:FormData)=>({...d, issueMain:e.target.value}))}>
            <option>Damp/Mould</option><option>Leaks</option><option>Heating</option>
            <option>Electrics</option><option>Pest</option><option>Structural</option><option>Other</option>
          </select>
        </label>
        <label className="block">How long has this been ongoing?
          <input className="mt-1 block w-full border rounded-lg p-2" placeholder="e.g., 6 months"
            value={data.issueDuration}
            onChange={e=>setData((d:FormData)=>({...d, issueDuration:e.target.value}))}/>
        </label>
      </div>
      <div className="mt-6 flex gap-3">
        <button onClick={onBack} className="px-4 py-2 rounded-lg border">Back</button>
        <button onClick={onNext} className="px-4 py-2 rounded-lg bg-blue-600 text-white">Continue</button>
      </div>
    
      <input type="text" name="hp" autoComplete="off" tabIndex="-1" className="hidden" onChange={() => {}} />
    </section>
  );
}

function StepCrossSell({ data, setData, onNext, onBack }:{
  data: FormData; setData:(u:any)=>void; onNext:()=>void; onBack:()=>void;
}) {
  const c = data.cross;
  return (
    <section>
      <h2 className="text-2xl font-semibold">Other issues we can help with</h2>
      <p className="text-gray-600 mt-2">Tick any that apply:</p>
      <div className="mt-4 space-y-3">
        <label className="block"><input type="checkbox" checked={c.debtsOrIVA} onChange={e=>setData((d:FormData)=>({...d, cross:{...d.cross, debtsOrIVA:e.target.checked}}))}/> I have debts or an IVA</label>
        <label className="block"><input type="checkbox" checked={c.badCredit} onChange={e=>setData((d:FormData)=>({...d, cross:{...d.cross, badCredit:e.target.checked}}))}/> I have bad credit / CCJs</label>
        <label className="block"><input type="checkbox" checked={c.pcp} onChange={e=>setData((d:FormData)=>({...d, cross:{...d.cross, pcp:e.target.checked}}))}/> I had PCP / Car Finance</label>
        <label className="block"><input type="checkbox" checked={c.payday} onChange={e=>setData((d:FormData)=>({...d, cross:{...d.cross, payday:e.target.checked}}))}/> I had payday / high APR loans</label>
        <label className="block"><input type="checkbox" checked={c.misSold} onChange={e=>setData((d:FormData)=>({...d, cross:{...d.cross, misSold:e.target.checked}}))}/> I think I was mis-sold insurance or add-ons</label>
      </div>
      <div className="mt-6 flex gap-3">
        <button onClick={onBack} className="px-4 py-2 rounded-lg border">Back</button>
        <button onClick={onNext} className="px-4 py-2 rounded-lg bg-blue-600 text-white">Continue</button>
      </div>
    
      <input type="text" name="hp" autoComplete="off" tabIndex="-1" className="hidden" onChange={() => {}} />
    </section>
  );
}

function StepSubmit({ data, onBack, onSubmit, busy, err }:{
  data: FormData; onBack:()=>void; onSubmit:()=>Promise<void>; busy:boolean; err:string|null;
}) {
  return (
    <section>
      <h2 className="text-2xl font-semibold">Submit your details</h2>
      <p className="mt-3 text-gray-600">We’ll review your case and get back to you.</p>
      {err && <p className="mt-2 text-red-600">{err}</p>}
      <div className="mt-6 flex gap-3">
        <button onClick={onBack} className="px-4 py-2 rounded-lg border" disabled={busy}>Back</button>
        <button onClick={onSubmit} className="px-4 py-2 rounded-lg bg-green-600 text-white" disabled={busy}>
          {busy ? "Submitting..." : "Submit"}
        </button>
      </div>
    
      <input type="text" name="hp" autoComplete="off" tabIndex="-1" className="hidden" onChange={() => {}} />
    </section>
  );
}
