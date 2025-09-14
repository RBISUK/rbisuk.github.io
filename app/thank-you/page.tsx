export default function ThankYou(){
  return (
    <main className="container py-16">
      <div className="card p-8 text-center">
        <h1 className="text-2xl font-semibold">Thanks — we’ve received your form ✅</h1>
        <p className="mt-3 text-gray-600">A trained human will review and contact you shortly with next steps.</p>
        <a href="/" className="mt-6 inline-block rounded border px-4 py-2">Back home</a>
      </div>
    </main>
  );
}
