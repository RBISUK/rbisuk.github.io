import "./globals.css";
export const metadata = {
  title: "RBIS UK — Housing Disrepair Claims",
  description: "Secure HDR intake. Evidence-led. Human-reviewed.",
};
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <header className="border-b">
          <nav className="container flex items-center justify-between py-4">
            <a href="/" className="font-semibold tracking-tight">RBIS <span className="text-blue-600">UK</span></a>
            <div className="flex items-center gap-6 text-sm">
              <a href="/form" className="text-blue-600 font-medium">Start claim</a>
              <a href="#how">How it works</a>
              <a href="#faqs">FAQs</a>
            </div>
          </nav>
        </header>
        {children}
        <footer className="mt-16 border-t">
          <div className="container py-10 text-sm text-gray-600">
            <p>© {new Date().getFullYear()} RBIS UK. GDPR-compliant, human-reviewed, audit-logged.</p>
          </div>
        </footer>
        <a href="/form" className="rbis-float"><span className="font-medium">Rapid Support</span></a>
      </body>
    </html>
  );
}
