// app/layout.tsx
import type { Metadata } from "next";
import "./globals.css";
import { Analytics } from "@vercel/analytics/react";

export const metadata: Metadata = {
  title: "RBIS — Repairs & Compliance Copilot",
  description:
    "RBIS builds audit-ready AI products: Claim-Fix-AI, OmniAssist, RBIS Dashboard, and NextusOne CRM.",
  metadataBase: new URL("https://www.rbisintelligence.com"),
  openGraph: {
    title: "RBIS — Repairs & Compliance Copilot",
    description:
      "Audit-ready AI for housing: repairs intake, compliance timers, SLA comms, and court-ready exports.",
    url: "https://www.rbisintelligence.com/main",
    siteName: "RBIS Intelligence",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "RBIS — Repairs & Compliance Copilot",
    description:
      "Audit-ready AI for housing providers and compliance-heavy orgs.",
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen antialiased text-slate-900 bg-white">
        <header className="sticky top-0 z-40 border-b">
          <nav className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
            <a href="/main" className="font-semibold">RBIS</a>
            <div className="space-x-4 text-sm">
              <a href="/main#products">Products</a>
              <a href="/main#pricing">Pricing</a>
              <a href="/main#contact">Contact</a>
            </div>
          </nav>
        </header>
        <main className="mx-auto max-w-6xl px-4">{children}</main>
        <footer className="mt-16 border-t">
          <div className="mx-auto max-w-6xl px-4 py-8 text-sm text-slate-600">
            © {new Date().getFullYear()} RBIS Intelligence — Audit-ready by design.
          </div>
        </footer>
        <Analytics />
      </body>
    </html>
  );
}
