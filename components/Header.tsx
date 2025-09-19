"use client";
import Link from "next/link";
export default function Header() {
  return (
    <header className="sticky top-0 z-50 border-b border-neutral-200 bg-white/90 backdrop-blur supports-[backdrop-filter]:bg-white/70">
      <div className="container flex h-14 items-center justify-between">
        <Link href="/" className="font-semibold tracking-tight" aria-label="RBIS Home">
          RBIS: Behavioural & Intelligence Services
        </Link>
        <nav className="hidden gap-6 md:flex">
          <Link href="/products" className="text-sm text-neutral-700 hover:underline">Products</Link>
          <Link href="/solutions" className="text-sm text-neutral-700 hover:underline">Solutions</Link>
          <Link href="/trust-centre" className="text-sm text-neutral-700 hover:underline">Trust Centre</Link>
          <Link href="/contact" className="text-sm text-neutral-700 hover:underline">Contact</Link>
        </nav>
        <div className="flex items-center gap-2">
          <Link href="/hdr" className="btn-primary text-sm" aria-label="Report Housing Disrepair">Report Housing Issue</Link>
        </div>
      </div>
    </header>
  );
}
