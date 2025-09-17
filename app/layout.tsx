import "./globals.css";
import Nav from "./components/Nav";
import Footer from "./components/Footer";

export const metadata = {
  title: "RBIS — Repairs & Compliance",
  description: "Audit-ready by design. Evidence-led housing repair and compliance intelligence."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Nav />
        <main className="container">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
