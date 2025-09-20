import Header from "@/components/Header";
import Link from "next/link";

export const metadata = {
  title: "RBIS: Behavioural & Intelligence Services",
  description: "Live robots. AI at the edge. Compliance-first systems. No static competitor can keep up."
};

export default function Home() {
  return (
    <>
      <Header />
      <main className="pb-28">
        <section className="container pt-12">
          <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight">
            Live robots. AI at the edge. Compliance-first systems. No static competitor can keep up.
          </h1>
          <div className="mt-6 flex flex-wrap gap-3">
            <Link href="/contact" className="btn-primary">Book a Demo</Link>
            <Link href="/products" className="btn border border-neutral-300 hover:bg-neutral-100">Explore the RBIS Suite</Link>
          </div>
        </section>
      </main>
    </>
  );
  import AdminUI from "./ui";

export const metadata = { title: "Veridex Admin | RBIS" };

export default function Page() {
  return <AdminUI />;
}
import AdminUI from "./ui";

export const metadata = { title: "Veridex Admin | RBIS" };

export default function Page() {
  return <AdminUI />;
}
