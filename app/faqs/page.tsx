export default function Faqs(){
  return (
    <div className="container py-16">
      <h1 className="text-3xl font-bold">FAQs</h1>
      <div className="mt-6 grid gap-4">
        <div className="card p-5">
          <div className="font-semibold">What counts as disrepair?</div>
          <p className="text-gray-300 mt-2">Damp/mould, leaks, heating failures, unsafe electrics, pests, structural issues and similar defects.</p>
        </div>
        <div className="card p-5">
          <div className="font-semibold">Will you sell my data?</div>
          <p className="text-gray-300 mt-2">No. We never sell personal data. We use it only to handle your enquiry, per our Privacy Policy.</p>
        </div>
        <div className="card p-5">
          <div className="font-semibold">Is this legal advice?</div>
          <p className="text-gray-300 mt-2">No. We triage and introduce to regulated partners where appropriate. Always read engagement terms.</p>
        </div>
      </div>
      <a className="btn btn-primary mt-8" href="/form">Start your claim</a>
    </div>
  );
}
