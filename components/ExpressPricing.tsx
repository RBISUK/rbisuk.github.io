export default function ExpressPricing({content}:{content:any}) {
  const { priceSetup, priceMonthly, bullets, lockIn } = content;
  return (
    <section aria-labelledby="express-title" className="mx-auto max-w-3xl sm:max-w-5xl px-4 py-12">
      <h2 id="express-title" className="text-2xl sm:text-3xl font-bold text-center">One Price. One Day. One System Nobody Else Can Match.</h2>
      <div className="mt-6 rounded-xl border border-neutral-200 shadow-sm bg-white">
        <div className="p-6 sm:p-8 text-center">
          <div className="text-3xl font-bold">{priceSetup}</div>
          <div className="mt-1 text-neutral-600">{priceMonthly}</div>
          <ul className="mt-6 space-y-2 text-left">
            {bullets.map((b:string,i:number)=>(
              <li key={i} className="flex items-start gap-2">
                <span aria-hidden>✅</span>
                <span className="text-sm sm:text-base">{b}</span>
              </li>
            ))}
          </ul>
          <div className="mt-4 text-sm italic text-amber-700">{lockIn}</div>
          <div className="mt-6">
            <a href="/contact" className="inline-flex w-full sm:w-auto justify-center rounded-lg px-5 py-3 text-white bg-black hover:bg-neutral-800 focus:outline-none focus:ring-2 focus:ring-black/40">Book My 24h Build</a>
          </div>
        </div>
      </div>
    </section>
  );
}
