import "./globals.css";
export const metadata = { title: "RBIS", description: "Live robots. Compliance-first systems." };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-dvh bg-[#f4f6ff] antialiased">{children}</body>
    </html>
  );
}
