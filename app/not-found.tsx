import Link from "next/link";
export default function NotFound() {
  return (
    <main className="p-10 space-y-4">
      <h1 className="text-2xl font-bold">Page not found</h1>
      <p>Try <Link href="/hdr" className="underline">HDR</Link> or <Link href="/main" className="underline">RBIS main</Link>.</p>
    </main>
  );
}
