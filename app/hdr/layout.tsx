<<<<<<< HEAD
import "./../globals.css";
import type { Metadata } from "next";
import Link from "next/link";
import SupportBubble from "../components/SupportBubble";

export const metadata: Metadata = {
  title: "Claim-Fix-AI — Intake at Super-Intelligence Speed",
  description: "One funnel. Every HDR pattern. Evidence in minutes.",
};

export default function HDRLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en"><body>
      <header className="bg-white border-b">
        <nav className="container mx-auto flex items-center justify-between p-4">
          <Link href="/hdr" className="font-semibold">Claim-Fix-AI</Link>
          <div className="flex gap-6">
            <Link href="/hdr/what-it-does">What it does</Link>
            <Link href="/hdr/form">Form</Link>
            <Link href="/hdr/dashboards">Dashboards</Link>
            <Link href="/hdr/pricing">Pricing</Link>
            <Link href="/main" className="btn btn-outline">RBIS Main</Link>
          </div>
        </nav>
      </header>
      <main className="container mx-auto p-6">{children}</main>
      <footer className="border-t text-sm text-gray-500">
        <div className="container mx-auto p-6">© {new Date().getFullYear()} RBIS</div>
      </footer>
      <SupportBubble/>
    </body></html>
  );
=======
export default function HdrLayout({ children }: { children: React.ReactNode }) {
  return <section>{children}</section>;
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef
}
