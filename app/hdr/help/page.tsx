export const metadata = { title: "HDR Help | RBIS" };
export default function HdrHelp() {
  return (
    <main className="container py-10">
      <h1 className="text-2xl font-bold">Help: Reporting Housing Disrepair</h1>
      <p className="mt-3 text-neutral-700 max-w-2xl">
        You can save and return. For emergencies, contact emergency services and your landlord immediately.
      </p>
      <h2 className="mt-6 font-semibold">Tips</h2>
      <ul className="mt-2 list-disc pl-5 space-y-1 text-neutral-800">
        <li>Take photos in good light; include context and detail shots.</li>
        <li>Note when it started and how it affects health or safety.</li>
        <li>Keep dates of reports, visits, and missed appointments.</li>
      </ul>
    </main>
  );
}
