export default function SiteNav(){
  return (
    <header className="border-b border-gray-200 bg-white/70 backdrop-blur">
      <div className="container h-16 flex items-center justify-between">
        <a href="/" className="font-bold text-xl">RBIS</a>
        <nav className="hidden md:flex gap-6 text-sm">
          <a href="/main" className="hover:underline">Products</a>
          <a href="/hdr" className="hover:underline">HDR Funnel</a>
          <a href="/faqs" className="hover:underline">FAQs</a>
          <a href="/form" className="btn btn-primary">Get a demo</a>
        </nav>
      </div>
    </header>
  );
}
