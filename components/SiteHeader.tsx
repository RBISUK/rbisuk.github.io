"use client";
import Link from "next/link";

export default function SiteHeader() {
  return (
    <header className="sticky top-0 z-50 bg-white/90 backdrop-blur border-b border-neutral-200">
      <div className="container flex h-14 items-center justify-between">
        <Link href="/" className="font-bold tracking-tight" aria-label="RBIS Home">
          RBIS
        </Link>
        <nav className="hidden sm:flex items-center gap-5 text-sm">
          <Link className="hover:underline" href="/products">Products</Link>
          <Link className="hover:underline" href="/services">Services</Link>
          <Link className="hover:underline" href="/reports">Reports</Link>
          <Link className="hover:underline" href="/dashboard">Dashboard</Link>
          <Link className="rounded-lg px-3 py-1.5 bg-black text-white hover:bg-neutral-800" href="/contact">Contact</Link>
        </nav>
        <div className="sm:hidden">
          <Link className="rounded-lg px-3 py-1.5 bg-black text-white" href="/contact">Contact</Link>
        </div>
      </div>
    </header>
  );
}
