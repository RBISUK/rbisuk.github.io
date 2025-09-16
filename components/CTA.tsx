import Link from "next/link";

export default function CTA() {
  return (
    <section className="py-20 bg-indigo-600 text-white text-center">
      <h2 className="text-3xl font-bold mb-6">Ready to get started?</h2>
      <Link href="/form" className="px-6 py-3 bg-white text-indigo-700 font-semibold rounded-lg shadow hover:bg-gray-100">
        Contact Us
      </Link>
    </section>
  );
}
