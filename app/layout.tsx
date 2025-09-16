import "./globals.css";
import type { ReactNode } from "react";

export const metadata = {
  title: "RBIS — Repairs & Compliance Copilot",
  description: "Claim-Fix-AI and RBIS modules for housing providers."
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="stylesheet" href="/styles/global.css" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </head>
      <body>{children}</body>
    </html>
  );
}
