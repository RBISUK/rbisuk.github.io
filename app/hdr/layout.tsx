export const metadata = {
  title: "RBIS — HDR Funnel",
  description: "High-Discovery/High-Delight RBIS marketing funnel.",
};

export default function HDRLayout({ children }: { children: React.ReactNode }) {
  return (
    <section className="min-h-screen bg-white text-slate-900">
      {children}
    </section>
  );
}
