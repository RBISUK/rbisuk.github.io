export default function How(){
  return (
    <div className="container py-16">
      <h1 className="text-3xl font-bold">How it works</h1>
      <ol className="mt-6 space-y-4 text-gray-300">
        <li><b>1) Tell us the basics.</b> We capture facts + your preferred contact.</li>
        <li><b>2) Evidence.</b> Upload photos, dates, reports, and repair history.</li>
        <li><b>3) Human triage.</b> We review within 1–2 business days and outline next steps.</li>
        <li><b>4) Action.</b> We connect you to the right pathway (complaint, escalation, legal partner).</li>
      </ol>
      <a className="btn btn-primary mt-8" href="/form">Start your claim</a>
    </div>
  );
}
