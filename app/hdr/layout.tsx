import HdrHeader from "@/components/hdr/HdrHeader";
import "../globals.css";
export const metadata = {
  title: "Report Housing Disrepair | RBIS",
  description: "Securely report disrepair and build an audit-ready evidence pack."
};
export default function HdrLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-neutral-50 text-neutral-900">
        <HdrHeader />
        <main className="container py-6">{children}</main>
      </body>
    </html>
  );
}
