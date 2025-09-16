'use client';
import Link from "next/link";

export default function Hero({ title, subtitle, ctaLabel, ctaLink }: { 
  title: string; subtitle: string; ctaLabel: string; ctaLink: string 
}) {
  return (
    <section className="bg-gradient-to-r from-indigo-600 to-blue-500 text-white py-20 text-center">
      <h1 className="text-4xl font-bold mb-4">{title}</h1>
      <p className="text-lg mb-6">{subtitle}</p>
      <Link href={ctaLink} className="px-6 py-3 bg-white text-indigo-700 font-semibold rounded-lg shadow hover:bg-gray-100">
        {ctaLabel}
      </Link>
    </section>
  );
}
