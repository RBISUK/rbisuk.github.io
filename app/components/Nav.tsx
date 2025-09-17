export default function Nav() {
  return (
    <header className="header">
      <nav className="container nav">
        <a href="/" style={{display:'flex',alignItems:'center',gap:8}}>
          <img src="/logo.svg" alt="RBIS" width={24} height={24}/> <strong>RBIS Intelligence</strong>
        </a>
        <ul>
          <li><a href="/#products">Products</a></li>
          <li><a href="/#pricing">Pricing</a></li>
          <li><a href="/#contact">Contact</a></li>
          <li><a className="btn" href="https://hdr.rbisintelligence.com">Start HDR</a></li>
        </ul>
      </nav>
    </header>
  );
}
