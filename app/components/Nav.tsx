"use client";
import Link from "next/link";

export default function Nav() {
  return (
    <header className="border-b border-slate-200 bg-white/80 backdrop-blur supports-[backdrop-filter]:bg-white/60">
      <div className="mx-auto max-w-6xl px-4 py-3 flex items-center justify-between">
        <Link href="/" className="font-semibold tracking-tight">RBIS</Link>
        <nav className="flex items-center gap-6 text-sm">
          <Link href="/hdr" className="hover:underline">HDR</Link>
          <Link href="/hdr/dashboards" className="hover:underline">HDR dashboards</Link>
          <Link href="/hdr/pricing" className="hover:underline">HDR pricing</Link>
          <Link href="/hdr/contact" className="hover:underline">HDR contact</Link>
          <span className="text-slate-300">|</span>
          <Link href="/main" className="hover:underline">RBIS main</Link>
          <Link href="/main/dashboards" className="hover:underline">Dashboards</Link>
          <Link href="/main/trust" className="hover:underline">Trust</Link>
          <Link href="/main/value" className="hover:underline">Value</Link>
          <Link href="/main/contact" className="btn">Contact</Link>
        </nav>
      </div>
    </header>
  );
}
