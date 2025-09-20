import "./globals.css";
import SiteHeader from "@/components/SiteHeader";

export const metadata = { title: "RBIS", description: "Live robots. Compliance-first systems." };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-dvh bg-[#f4f6ff] text-neutral-900 antialiased">
        <SiteHeader />
        <main>{children}</main>
      </body>
    </html>
  );
}
