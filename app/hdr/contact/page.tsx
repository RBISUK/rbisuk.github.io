export default function HDRContact(){
  return (
    <section className="space-y-4 max-w-lg">
      <h1 className="text-2xl font-semibold">Contact for HDR pilot</h1>
      <p className="text-slate-600">Email: <a className="underline" href="mailto:contact@rbisintelligence.com">contact@rbisintelligence.com</a></p>
      <form className="space-y-3 card" action="/api/submit" method="post">
        <label className="block text-sm">Organisation<input name="org" className="mt-1 w-full rounded border p-2"/></label>
        <label className="block text-sm">Email<input name="email" className="mt-1 w-full rounded border p-2" type="email"/></label>
        <label className="block text-sm">Notes<textarea name="notes" className="mt-1 w-full rounded border p-2" rows={4}/></label>
        <button className="btn">Request pilot</button>
      </form>
    </section>
  );
}
