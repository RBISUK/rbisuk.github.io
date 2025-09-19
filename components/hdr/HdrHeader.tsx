"use client";
import Link from "next/link";
export default function HdrHeader() {
  return (
    <header className="border-b border-neutral-200 bg-white">
      <div className="container flex h-14 items-center justify-between">
        <Link href="/" className="flex items-center gap-2" aria-label="RBIS Home">
          <span className="font-bold tracking-tight">RBIS</span>
          <span className="hidden sm:inline text-sm text-neutral-600">Housing Disrepair</span>
        </Link>
        <nav className="flex items-center gap-4 text-sm">
          <Link href="/hdr/help" className="hover:underline">Help</Link>
          <Link href="/contact" className="hover:underline">Contact</Link>
        </nav>
      </div>
    </header>
  );
}
