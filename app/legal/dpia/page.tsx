export default function DPIA() {
  return (
    <main className="prose max-w-3xl mx-auto p-6">
      <h1>Data Protection Impact Assessment (Summary)</h1>

      <h2>Overview</h2>
      <p>We identify and mitigate data protection risks in the RBIS Intake Portal.</p>

      <h2>Why It’s Needed</h2>
      <ul>
        <li>Potentially sensitive data (GDPR Art. 9)</li>
        <li>Legal triage context</li>
        <li>Submission audit logging</li>
      </ul>

      <h2>Mitigation Measures</h2>
      <ul>
        <li>Layered, explicit consent</li>
        <li>No automated decisions</li>
        <li>Data minimisation</li>
        <li>Retention controls</li>
        <li>TLS in transit</li>
      </ul>

      <h2>Risk Level</h2>
      <p>Low–moderate with mitigations and human review in place.</p>

      <h2>Contact</h2>
      <p>For the full DPIA, email: dpo@rbis.uk</p>
    </main>
  );
}
