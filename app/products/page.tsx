import Link from "next/link";
import { rbisContent } from "../config/rbisContent";

export default function Products() {
  return (
    <main className="mx-auto max-w-4xl px-4 py-12">
      <h1 className="text-3xl font-bold">RBIS Product Suite</h1>
      <ul className="mt-6 space-y-3">
        {rbisContent.products.map(p => (
          <li key={p.href}>
            <Link href={p.href} className="underline">{p.name}</Link>
            <span className="text-neutral-600"> — {p.tagline}</span>
          </li>
        ))}
      </ul>
    </main>
  );
}
