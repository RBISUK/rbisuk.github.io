export const metadata = {
  title: "Value & flexible models",
  description: "Worth, not price: fair models without lock-in.",
};
export default function Page() {
  return (
    <article className="prose max-w-none">
      <h1>Value, not price</h1>
      <p>
        Clients typically report the system is worth <strong>£800–£1,000 per qualified case</strong> in combined
        staff-time savings, faster triage, and improved evidence outcomes. We keep pricing flexible and fair to
        match volume, sector, and integration complexity — without lock-ins.
      </p>
      <ul>
        <li><strong>Flat SaaS:</strong> predictable monthly to run the full pipeline.</li>
        <li><strong>Hybrid:</strong> lower base + modest per-case to align incentives.</li>
        <li><strong>Rev-share:</strong> CMC-friendly, tied to solicitor outcomes.</li>
      </ul>
      <p><a className="btn btn-primary" href="/main/contact">Talk to us</a> — we’ll size it transparently and keep it fair.</p>
    </article>
  );
}
