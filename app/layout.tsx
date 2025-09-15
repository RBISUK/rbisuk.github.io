import "./globals.css";
import Nav from "./components/Nav";
import SupportBubble from "./components/SupportBubble";

export const metadata = {
  title: "RBIS — Intelligence & HDR",
  description: "RBIS Intelligence — compliance-first, AI-native services and HDR Claim-Fix-AI funnel.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen antialiased bg-gradient-to-b from-slate-50 to-white text-slate-900">
        <Nav />
        <main className="mx-auto max-w-7xl px-4 py-10">{children}</main>
        <SupportBubble/>
      </body>
    </html>
  );
}
