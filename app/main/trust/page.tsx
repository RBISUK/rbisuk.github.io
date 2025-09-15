export const metadata = {
  title: "Trust & Assurance — RBIS",
  description: "Security, privacy, governance, and audit posture (defaults).",
};
export default function Page() {
  return (
    <article className="prose max-w-none">
      <h1>Trust & Assurance</h1>
      <h2>Security</h2>
      <ul>
        <li>Zero-Trust access with SSO/MFA and least-privilege roles.</li>
        <li>Short-lived tokens; WAF/DDoS; rate limits; mTLS/HMAC webhooks.</li>
        <li>TLS 1.3 in transit; at-rest encryption across DB/cache/storage.</li>
      </ul>
      <h2>Privacy & Legal</h2>
      <ul>
        <li>Lawful bases: Art. 6 (Contract/LI); special category via Art. 9(2)(f).</li>
        <li>PECR-compliant comms; consent ledger; DSR export/redaction.</li>
        <li>Retention defaults; cryptographic erasure on delete.</li>
      </ul>
      <h2>Observability</h2>
      <ul>
        <li>Hash-chained audit logs; anomaly alerts on export/role change.</li>
      </ul>
      <p className="text-sm text-gray-500">Not legal advice — policies evolve; we track changes and update safely.</p>
    </article>
  );
}
