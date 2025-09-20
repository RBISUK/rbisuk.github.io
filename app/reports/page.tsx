export const metadata = { title: "Reports | RBIS" };
export default function Reports() {
  return (
    <section className="container py-10">
      <h1 className="text-3xl font-bold">Reports & Evidence</h1>
      <p className="mt-3 max-w-2xl text-neutral-700">
        Export regulator-ready packs: SLAs, timelines, event logs, and Verdiex journey transcripts with consent proofs.
      </p>
      <ul className="mt-6 space-y-2 text-neutral-800">
        <li>• Ombudsman pack (PDF)</li>
        <li>• Landlord/Provider pack (PDF + CSV)</li>
        <li>• Journey transcript with redactions (JSONL)</li>
      </ul>
    </section>
  );
}
