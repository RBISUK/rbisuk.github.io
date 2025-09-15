export default function Section({title, children}:{title:string;children:React.ReactNode}) {
  return (
    <section className="max-w-4xl mx-auto px-5 py-10">
      <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">{title}</h2>
      <div className="mt-4 text-gray-700 leading-relaxed">{children}</div>
    </section>
  );
}
