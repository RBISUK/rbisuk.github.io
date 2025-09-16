import "./globals.css";
<<<<<<< HEAD
import Nav from "./components/Nav";
import SupportBubble from "./components/SupportBubble";

export const metadata = {
  title: "RBIS — Intelligence & HDR",
  description: "RBIS Intelligence — compliance-first, AI-native services and HDR Claim-Fix-AI funnel.",
};
=======
import GA from "@/components/GA";
import type { ReactNode } from "react";
import { metadata as exportedMetadata } from "./layout.metadata";
import { Analytics } from "@vercel/analytics/react";

export const metadata = exportedMetadata;
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
<<<<<<< HEAD
      <body className="min-h-screen antialiased bg-gradient-to-b from-slate-50 to-white text-slate-900">
        <Nav />
        <main className="mx-auto max-w-7xl px-4 py-10">{children}</main>
        <SupportBubble/>
=======
      <body>
        {children}
        <Analytics />
        <GA />
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef
      </body>
    </html>
  );
}
