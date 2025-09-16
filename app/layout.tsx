import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "RBIS Intelligence",
  description: "Repairs & Compliance Copilot – Ryan Roberts: Behavioural & Intelligence Services",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      {/* If Tailwind is working, you will get gray background and dark text */}
      <body className="min-h-screen bg-gray-50 text-gray-900 antialiased">{children}</body>
    </html>
  );
}
