import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  metadataBase: new URL("https://www.rbisintelligence.com"),
  title: "RBIS Intelligence",
  description: "Repairs & Compliance Copilot – Ryan Roberts: Behavioural & Intelligence Services",
  themeColor: "#111827",
  manifest: "/manifest.json",
  icons: {
    icon: "/favicon.ico",
    apple: "/icons/icon-192.png",
  },
  openGraph: {
    type: "website",
    url: "https://www.rbisintelligence.com/",
    title: "RBIS Intelligence",
    description: "Repairs & Compliance Copilot – Ryan Roberts: Behavioural & Intelligence Services",
    images: [{ url: "/og-image.png", width: 1200, height: 630 }],
  },
  twitter: {
    card: "summary_large_image",
    title: "RBIS Intelligence",
    description: "Repairs & Compliance Copilot – Ryan Roberts: Behavioural & Intelligence Services",
    images: ["/og-image.png"],
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
