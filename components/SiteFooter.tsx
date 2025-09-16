export default function SiteFooter(){
  return (
    <footer className="border-t border-gray-200">
      <div className="container py-10 text-sm text-gray-600 flex flex-col md:flex-row gap-4 md:items-center md:justify-between">
        <p>© RBIS LTD</p>
        <nav className="flex gap-4">
          <a href="/legal/privacy">Privacy</a>
          <a href="/legal/terms">Terms</a>
          <a href="/legal/cookies">Cookies</a>
          <a href="/sitemap.xml">Sitemap</a>
        </nav>
      </div>
    </footer>
  );
}
