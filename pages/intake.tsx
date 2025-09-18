import { useEffect, useMemo, useState } from "react";
import Head from "next/head";

type IssueKey = "damp" | "leaks" | "heating" | "electrics" | "structure" | "pests" | "other";

type FormState = {
  fullName: string;
  email: string;
  role: "Tenant" | "Leaseholder" | "Homeowner" | "Other" | "";
  address: string;
  issues: IssueKey[];
  otherIssueText: string;
  evidence: File[];
  evidenceNotes: string;
  startedOn: string;
  reportedBefore: "Yes" | "No" | "";
  actionsTaken: string;
  healthImpact: "Yes" | "No" | "";
  vulnerability: "Yes" | "No" | "";
  impactNotes: string;
};

const STORAGE_KEY = "hdr-intake-v1";

const s = {
  wrap: { fontFamily: "system-ui", color: "#111", padding: "24px", maxWidth: 980, margin: "0 auto" } as React.CSSProperties,
  step: { border: "1px solid #eee", borderRadius: 12, padding: 20, marginTop: 16 } as React.CSSProperties,
  row: { display: "grid", gap: 10, margin: "8px 0" } as React.CSSProperties,
  label: { fontWeight: 600, fontSize: 14 } as React.CSSProperties,
  input: { padding: 10, border: "1px solid #ccc", borderRadius: 8 } as React.CSSProperties,
  hint: { fontSize: 12, color: "#666" } as React.CSSProperties,
  error: { fontSize: 12, color: "#b30000" } as React.CSSProperties,
  chips: { display: "flex", gap: 8, flexWrap: "wrap" } as React.CSSProperties,
  chip: (active: boolean) =>
    ({ padding: "8px 12px", borderRadius: 999, border: "1px solid #ccc", background: active ? "#111" : "#fff", color: active ? "#fff" : "#111", cursor: "pointer" }) as React.CSSProperties,
  nav: { display: "flex", gap: 8, marginTop: 16, flexWrap: "wrap" } as React.CSSProperties,
  btn: (kind: "pri" | "sec" | "ghost" = "pri", disabled = false) =>
    ({
      padding: "10px 14px",
      borderRadius: 8,
      border: kind === "sec" ? "1px solid #111" : "none",
      background: kind === "pri" ? (disabled ? "#999" : "#111") : kind === "sec" ? "#fff" : "transparent",
      color: kind === "sec" ? "#111" : "#fff",
      opacity: disabled ? 0.7 : 1,
      cursor: disabled ? "not-allowed" : "pointer",
      textDecoration: "none",
    }) as React.CSSProperties,
  grid: { display: "grid", gap: 16, gridTemplateColumns: "repeat(auto-fit, minmax(220px,1fr))" } as React.CSSProperties,
  preview: { display: "grid", gap: 10, gridTemplateColumns: "repeat(auto-fit, minmax(140px,1fr))" } as React.CSSProperties,
  bar: { height: 6, background: "#eee", borderRadius: 999, overflow: "hidden" } as React.CSSProperties,
  barFill: (pct: number) => ({ height: "100%", width: `${pct}%`, background: "#111" }) as React.CSSProperties,
};

export default function HDRIntake() {
  const [step, setStep] = useState<number>(1);
  const [state, setState] = useState<FormState>({
    fullName: "", email: "", role: "", address: "",
    issues: [], otherIssueText: "",
    evidence: [], evidenceNotes: "",
    startedOn: "", reportedBefore: "", actionsTaken: "",
    healthImpact: "", vulnerability: "", impactNotes: "",
  });

  useEffect(() => {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      try { const parsed = JSON.parse(raw); setState((old) => ({ ...old, ...parsed })); } catch {}
    }
  }, []);
  useEffect(() => {
    const { evidence, ...safe } = state;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(safe));
  }, [state]);

  const issueLabels: Record<IssueKey, string> = {
    damp: "Damp / mould",
    leaks: "Leaks / water ingress",
    heating: "Heating / hot water",
    electrics: "Electrics",
    structure: "Structure (walls, roof, windows)",
    pests: "Pests / infestation",
    other: "Other",
  };

  const stepsTotal = 6;
  const pct = Math.round((step - 1) / (stepsTotal - 1) * 100);

  const stepValid = useMemo(() => {
    switch (step) {
      case 1: return !!state.fullName.trim() && emailOk(state.email) && !!state.role && !!state.address.trim();
      case 2: return state.issues.length > 0 && !(state.issues.includes("other") && !state.otherIssueText.trim());
      case 3: return state.evidence.every(isAllowedFile);
      case 4: return !!state.startedOn && !!state.reportedBefore;
      case 5: return !!state.healthImpact && !!state.vulnerability;
      case 6: return true;
      default: return false;
    }
  }, [step, state]);

  const next = () => setStep((s) => Math.min(stepsTotal, s + 1));
  const back = () => setStep((s) => Math.max(1, s - 1));

  const onChip = (key: IssueKey) => {
    setState((s0) => {
      const selected = new Set(s0.issues);
      selected.has(key) ? selected.delete(key) : selected.add(key);
      return { ...s0, issues: Array.from(selected) as IssueKey[] };
    });
  };

  const onEvidence = (files: FileList | null) => {
    if (!files) return;
    const nextFiles: File[] = [];
    for (const f of Array.from(files)) if (isAllowedFile(f)) nextFiles.push(f);
    setState((s0) => ({ ...s0, evidence: [...s0.evidence, ...nextFiles].slice(0, 10) }));
  };

  const onSubmit = () => {
    const subject = encodeURIComponent(`HDR Intake — ${state.fullName}`);
    const lines: string[] = [
      "HDR Intake Summary",
      "-------------------",
      `Name: ${state.fullName}`,
      `Email: ${state.email}`,
      `Role: ${state.role}`,
      `Address: ${state.address}`,
      "",
      `Issues: ${state.issues.map(i => issueLabels[i]).join(", ")}`,
      ...(state.issues.includes("other") && state.otherIssueText ? [`Other details: ${state.otherIssueText}`] : []),
      "",
      `Evidence notes: ${state.evidenceNotes || "-"}`,
      `Evidence files (not attached, listed only):`,
      ...state.evidence.map(f => ` - ${f.name} (${Math.round(f.size/1024)} KB)`),
      "",
      `Started on: ${state.startedOn}`,
      `Reported before: ${state.reportedBefore}`,
      `Actions taken: ${state.actionsTaken || "-"}`,
      "",
      `Health impact: ${state.healthImpact}`,
      `Vulnerability: ${state.vulnerability}`,
      `Impact notes: ${state.impactNotes || "-"}`,
      "",
      `Source URL: ${typeof window !== "undefined" ? window.location.href : ""}`,
      `Timestamp: ${new Date().toISOString()}`,
      `User-Agent: ${typeof navigator !== "undefined" ? navigator.userAgent : ""}`,
    ];
    const body = encodeURIComponent(lines.join("\n"));
    window.location.href = `mailto:Contact@RBISIntelligence.com?subject=${subject}&body=${body}`;
  };

  return (
    <>
      <Head>
        <title>HDR Intake — Guided Funnel</title>
        <meta name="description" content="Guided HDR intake with behavioural prompts, timeline, and evidence hints. Autosaves your progress." />
      </Head>

      <main style={s.wrap}>
        <h1>HDR Intake</h1>
        <div style={s.bar}><div style={s.barFill(pct)} /></div>
        <p style={s.hint}>Step {step} of {stepsTotal}</p>

        {step === 1 && (
          <section style={s.step} aria-labelledby="s1">
            <h2 id="s1">About you</h2>
            <div style={s.row}>
              <label style={s.label} htmlFor="name">Full name</label>
              <input id="name" style={s.input} value={state.fullName} onChange={e => setState({ ...state, fullName: e.target.value })} placeholder="Jane Doe" />
            </div>
            <div style={s.row}>
              <label style={s.label} htmlFor="email">Email</label>
              <input id="email" type="email" style={s.input} value={state.email} onChange={e => setState({ ...state, email: e.target.value })} placeholder="jane@example.com" />
              {!!state.email && !emailOk(state.email) && <span style={s.error}>Please enter a valid email.</span>}
            </div>
            <div style={s.row}>
              <label style={s.label} htmlFor="role">I am a…</label>
              <select id="role" style={s.input} value={state.role} onChange={e => setState({ ...state, role: e.target.value as any })}>
                <option value="">Select</option>
                <option>Tenant</option>
                <option>Leaseholder</option>
                <option>Homeowner</option>
                <option>Other</option>
              </select>
            </div>
            <div style={s.row}>
              <label style={s.label} htmlFor="addr">Property address</label>
              <input id="addr" style={s.input} value={state.address} onChange={e => setState({ ...state, address: e.target.value })} placeholder="Building, Street, City, Postcode" />
            </div>
            <p style={s.hint}>We collect the minimum needed to process your report. See <a href="/trust-centre">Trust Centre</a>.</p>
          </section>
        )}

        {step === 2 && (
          <section style={s.step} aria-labelledby="s2">
            <h2 id="s2">What’s wrong?</h2>
            <div style={s.chips} role="group" aria-label="Issue types">
              {(["damp","leaks","heating","electrics","structure","pests","other"] as IssueKey[]).map(k => (
                <button key={k} type="button" onClick={() => onChip(k)} style={s.chip(state.issues.includes(k))}>
                  {issueLabels[k]}
                </button>
              ))}
            </div>
            {state.issues.includes("other") && (
              <div style={s.row}>
                <label style={s.label} htmlFor="other">Other details</label>
                <input id="other" style={s.input} value={state.otherIssueText} onChange={e => setState({ ...state, otherIssueText: e.target.value })} placeholder="Describe the issue" />
              </div>
            )}
            {state.issues.includes("damp") && <div style={s.row}><span style={s.hint}><b>Damp guidance:</b> Wide photo of wall + close-ups of mould.</span></div>}
            {state.issues.includes("leaks") && <div style={s.row}><span style={s.hint}><b>Leak guidance:</b> Source, damage, mitigations.</span></div>}
          </section>
        )}

        {step === 3 && (
          <section style={s.step} aria-labelledby="s3">
            <h2 id="s3">Add evidence (optional)</h2>
            <p style={s.hint}>Up to 10 files. Images/videos only. We’ll request originals via secure link if needed.</p>
            <input type="file" accept="image/*,video/*" multiple onChange={e => onEvidence(e.target.files)} />
            <div style={s.row}>
              <label style={s.label} htmlFor="evnotes">Notes (what’s in your media)</label>
              <textarea id="evnotes" rows={4} style={s.input} value={state.evidenceNotes} onChange={e => setState({ ...state, evidenceNotes: e.target.value })} />
            </div>
            {!!state.evidence.length && (
              <div style={s.preview}>
                {state.evidence.map((f, i) => (
                  <div key={i} style={{ border: "1px solid #eee", borderRadius: 8, padding: 8 }}>
                    <div style={{ fontSize: 12 }}>{f.name}</div>
                    <div style={{ fontSize: 12, color: "#666" }}>{Math.round(f.size/1024)} KB</div>
                  </div>
                ))}
              </div>
            )}
          </section>
        )}

        {step === 4 && (
          <section style={s.step} aria-labelledby="s4">
            <h2 id="s4">Timeline</h2>
            <div style={s.grid}>
              <div style={s.row}>
                <label style={s.label} htmlFor="start">When did it start?</label>
                <input id="start" type="date" style={s.input} value={state.startedOn} onChange={e => setState({ ...state, startedOn: e.target.value })} />
              </div>
              <div style={s.row}>
                <label style={s.label} htmlFor="rep">Have you reported this before?</label>
                <select id="rep" style={s.input} value={state.reportedBefore} onChange={e => setState({ ...state, reportedBefore: e.target.value as any })}>
                  <option value="">Select</option>
                  <option>Yes</option>
                  <option>No</option>
                </select>
              </div>
            </div>
            <div style={s.row}>
              <label style={s.label} htmlFor="actions">What’s been tried so far?</label>
              <textarea id="actions" rows={4} style={s.input} value={state.actionsTaken} onChange={e => setState({ ...state, actionsTaken: e.target.value })} placeholder="E.g., reported on 01/08, contractor visited 10/08, temporary fix failed 20/08." />
            </div>
          </section>
        )}

        {step === 5 && (
          <section style={s.step} aria-labelledby="s5">
            <h2 id="s5">Impact & vulnerabilities</h2>
            <div style={s.grid}>
              <div style={s.row}>
                <label style={s.label} htmlFor="health">Has this affected anyone’s health?</label>
                <select id="health" style={s.input} value={state.healthImpact} onChange={e => setState({ ...state, healthImpact: e.target.value as any })}>
                  <option value="">Select</option>
                  <option>Yes</option>
                  <option>No</option>
                </select>
              </div>
              <div style={s.row}>
                <label style={s.label} htmlFor="vuln">Are there vulnerabilities we should know?</label>
                <select id="vuln" style={s.input} value={state.vulnerability} onChange={e => setState({ ...state, vulnerability: e.target.value as any })}>
                  <option value="">Select</option>
                  <option>Yes</option>
                  <option>No</option>
                </select>
              </div>
            </div>
            <div style={s.row}>
              <label style={s.label} htmlFor="impact">Anything else we should know?</label>
              <textarea id="impact" rows={4} style={s.input} value={state.impactNotes} onChange={e => setState({ ...state, impactNotes: e.target.value })} />
            </div>
            <p style={s.hint}>We only ask what’s necessary to help you. See our <a href="/trust-centre">Trust Centre</a>.</p>
          </section>
        )}

        {step === 6 && (
          <section style={s.step} aria-labelledby="s6">
            <h2 id="s6">Review & submit</h2>
            <ul>
              <li><b>Name:</b> {state.fullName}</li>
              <li><b>Email:</b> {state.email}</li>
              <li><b>Role:</b> {state.role || "-"}</li>
              <li><b>Address:</b> {state.address || "-"}</li>
              <li><b>Issues:</b> {state.issues.map(i => issueLabels[i]).join(", ") || "-"}</li>
              {state.issues.includes("other") && <li><b>Other:</b> {state.otherIssueText || "-"}</li>}
              <li><b>Started on:</b> {state.startedOn || "-"}</li>
              <li><b>Reported before:</b> {state.reportedBefore || "-"}</li>
              <li><b>Actions:</b> {state.actionsTaken || "-"}</li>
              <li><b>Health impact:</b> {state.healthImpact || "-"}</li>
              <li><b>Vulnerability:</b> {state.vulnerability || "-"}</li>
              <li><b>Impact notes:</b> {state.impactNotes || "-"}</li>
              <li><b>Evidence files:</b> {state.evidence.length ? `${state.evidence.length} file(s)` : "None attached (listed in email)"}</li>
            </ul>
            <p style={s.hint}>Submitting opens your email client with a structured summary. We’ll reply with a secure upload link if we need originals.</p>
          </section>
        )}

        <div style={s.nav}>
          {step > 1 && <button onClick={back} style={s.btn("sec")}>Back</button>}
          {step < stepsTotal && <button onClick={next} style={s.btn("pri", !stepValid)} disabled={!stepValid}>Next</button>}
          {step === stepsTotal && <button onClick={onSubmit} style={s.btn("pri")}>Submit</button>}
          <button onClick={() => { localStorage.removeItem(STORAGE_KEY); setState({ ...state, evidence: [] }); alert("Local draft cleared."); }} style={s.btn("ghost")} type="button">Clear draft</button>
        </div>
      </main>
    </>
  );
}

function emailOk(v: string){ return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v); }
function isAllowedFile(f: File){ return (/^image\/|^video\//.test(f.type)) && f.size <= 25*1024*1024; }
