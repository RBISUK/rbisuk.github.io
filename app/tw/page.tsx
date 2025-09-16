export const dynamic = "force-static";
export default function TWTest() {
  return (
    <main className="p-8 space-y-6">
      <h1 className="text-3xl font-bold">Tailwind Test</h1>
      <div className="rounded-lg bg-emerald-500 p-8 text-white shadow-lg">
        If you see a BIG emerald box with white text, Tailwind is working.
      </div>
      <p className="text-sm text-gray-600">Classes in use: bg-emerald-500, text-white, rounded-lg, shadow-lg, p-8.</p>
    </main>
  );
}
