import Link from "next/link";
import SupportBubble from "../components/SupportBubble";

export default function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <header className="bg-white border-b">
        <nav className="container mx-auto flex items-center justify-between py-4">
          <div className="flex space-x-6">
            <Link href="/main/trust">Trust</Link>
            <Link href="/main/dashboards">Dashboards</Link>
            <Link href="/main/pricing">Pricing</Link>
            <Link href="/main/contact">Contact</Link>
            <Link href="/hdr" className="btn btn-primary">Claim-Fix AI</Link>
          </div>
        </nav>
      </header>

      <main className="container mx-auto p-6">{children}</main>

      <footer className="border-t mt-10 py-6 text-center text-gray-500">
        © {new Date().getFullYear()} RBIS Intelligence
      </footer>

      <SupportBubble />
    </>
  );
}
