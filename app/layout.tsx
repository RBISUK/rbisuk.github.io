export const metadata = { title: "RBIS UK", description: "Housing Disrepair Intake" };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col">
        <nav className="w-full bg-blue-600 text-white py-3">
          <div className="max-w-5xl mx-auto px-4 flex justify-between">
            <a href="/" className="font-bold">RBIS UK</a>
            <a href="/form" className="underline">Start claim</a>
          </div>
        </nav>
        <main className="flex-1 w-full">{children}</main>
        <footer className="bg-gray-100 text-gray-700 text-xs text-center py-6">
          We comply with GDPR; forms are reviewed by humans (no automated decisions).
        </footer>
      </body>
    </html>
  );
}
