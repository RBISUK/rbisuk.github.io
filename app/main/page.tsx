export default function RBISHome() {
  return (
    <main className="p-8">
      <h1 className="text-3xl font-bold">RBIS Intelligence</h1>
      <p data-smoke="main">RBIS main OK</p>
      <nav className="mt-6 grid gap-2">
        <a href="/main/dashboards">Dashboards</a>
        <a href="/main/trust">Trust</a>
        <a href="/main/value">Value</a>
        <a href="/main/contact">Contact</a>
      </nav>
    </main>
  );
}
