import Link from "next/link";
export default function Solutions(){
  return (
    <main style={{padding:"2rem", fontFamily:"system-ui", lineHeight:1.5, maxWidth:980, margin:"0 auto"}}>
      <h1>Solutions</h1>
      <h2>Consulting</h2>
      <ul>
        <li>Strategic Audits — compliance, operations, data protection, governance</li>
        <li>Behavioural & Intelligence Advisory — decision frameworks, evidence-based strategy</li>
        <li>Execution Packages — adaptive workflows, automations, audit-ready systems</li>
      </ul>
      <h2>Products</h2>
      <ul>
        <li><Link href="/veridex">Veridex</Link> — Compliance at First Contact (adaptive intake)</li>
        <li><Link href="/pact-ledger">PACT Ledger</Link> — Promises made clear, kept, enforceable</li>
        <li>OmniAssist • NextusOne CRM • RBIS Dashboard</li>
      </ul>
      <h2>Bundles</h2>
      <ul>
        <li>Compliance Core — Website + Veridex Basic + RBIS Dashboard</li>
        <li>Professional (Recommended) — Veridex Pro + PACT Ledger Basic + OmniAssist</li>
        <li>Sovereign Enterprise — Veridex Ent + PACT Ledger Ent + NextusOne CRM</li>
      </ul>
    </main>
  );
}
