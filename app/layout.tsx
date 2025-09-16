import "./globals.css";
import GA from "@/components/GA";
import type { ReactNode } from "react";
import { metadata as exportedMetadata } from "./layout.metadata";
import { Analytics } from "@vercel/analytics/react";

export const metadata = exportedMetadata;

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        {children}
        <Analytics />
        <GA />
      </body>
    </html>
  );
}
