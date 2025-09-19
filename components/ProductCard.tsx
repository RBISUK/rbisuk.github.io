import Link from "next/link";
export default function ProductCard({name, tagline, href}:{name:string;tagline:string;href:string}) {
  return (
    <Link href={href} className="block rounded-lg border border-neutral-200 hover:shadow-md transition p-5 bg-white focus:outline-none focus:ring-2 focus:ring-black/40">
      <h3 className="text-lg font-semibold">{name}</h3>
      <p className="text-sm text-neutral-600 mt-1">{tagline}</p>
      <span className="inline-block mt-3 text-sm font-medium underline">Learn more</span>
    </Link>
  );
}
