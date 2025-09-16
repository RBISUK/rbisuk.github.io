<<<<<<< HEAD
import "./../globals.css";
import type { Metadata } from "next";
import Link from "next/link";
import SupportBubble from "../components/SupportBubble";

export const metadata: Metadata = {
  title: "RBIS Intelligence — Behavioural & Intelligence Services",
  description: "Ryan Roberts: Behavioural & Intelligence Services. Compliance-first, AI-native systems.",
};

export default function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en"><body>
      <header className="bg-white border-b">
        <nav className="container mx-auto flex items-center justify-between p-4">
          <Link href="/main" className="font-semibold">RBIS Intelligence</Link>
          <div className="flex gap-6">
            <Link href="/main/trust">Trust</Link>
            <Link href="/main/dashboards">Dashboards</Link>
            <Link href="/main/pricing">Pricing</Link>
            <Link href="/main/contact">Contact</Link>
            <Link href="/hdr" className="btn btn-primary">HDR Funnel</Link>
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
export default function MainLayout({ children }: { children: React.ReactNode }) {
  return <section>{children}</section>;
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef
}
