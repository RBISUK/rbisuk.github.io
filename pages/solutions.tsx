import Link from "next/link";
export default function Solutions(){
  return (
    <main style={{padding:"2rem", fontFamily:"system-ui", lineHeight:1.5, maxWidth:980, margin:"0 auto"}}>
      <h1>Solutions</h1>
      <h2>Consulting</h2>
      <ul>
        <li>Strategic Audits (compliance, operations, data protection, governance)</li>
        <li>Behavioural & Intelligence Advisory</li>
        <li>Execution Packages (workflows, automation, audit-ready systems)</li>
      </ul>
      <h2>Products</h2>
      <ul>
        <li><Link href="/veridex">Veridex</Link> — Compliance at First Contact</li>
        <li><Link href="/pact-ledger">PACT Ledger</Link> — Promises made clear, kept, enforceable</li>
        <li>OmniAssist • NextusOne CRM • RBIS Dashboard</li>
      </ul>
    </main>
  );
}
