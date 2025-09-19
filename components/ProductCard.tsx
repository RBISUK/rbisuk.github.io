import Link from "next/link";
export default function ProductCard(
  { name, tagline, href }: { name:string; tagline:string; href:string }
) {
  return (
    <Link
      href={href}
      className="card block p-5 transition hover:shadow-md focus:outline-none focus:ring-2 focus:ring-black/40"
      aria-label={`${name}: ${tagline}`}
    >
      <h3 className="text-lg font-semibold">{name}</h3>
      <p className="mt-1 text-sm text-neutral-600">{tagline}</p>
      <span className="mt-3 inline-block text-sm font-medium underline">Learn more</span>
    </Link>
  );
}
