#!/usr/bin/env bash
# v4 — safe/idempotent head + nav tidy for all *.html
set -Eeuo pipefail; IFS=$'\n\t'

# Gather HTML files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

# Ensure assets dir
mkdir -p assets

# Write small runtimes (idempotent overwrite)
cat > assets/nav-current.js <<'JS'
(()=>{try{
  const norm=p=>(p||"/").replace(/index\.html?$/,"").replace(/\/+$/,"/")||"/";
  const here=norm(location.pathname);
  document.querySelectorAll('nav a[href]').forEach(a=>{
    const href=norm(a.getAttribute('href')||'');
    if(href===here || href.replace(/\/$/,'')===here.replace(/\/$/,'')){
      a.setAttribute('aria-current','page');
    }
  });
}catch(e){}})();
JS

cat > assets/sw-register.js <<'JS'
if('serviceWorker' in navigator){
  addEventListener('load',()=>{ navigator.serviceWorker.register('/sw.js').catch(()=>{}); });
}
JS

for f in "${FILES[@]}"; do
  # 1) Remove malformed preconnects like href="index.html:https://…"
  perl -0777 -pe 's#\s*<link\b(?=[^>]*\brel="[^"]*\bpreconnect\b)[^>]*\bhref="(?!https?://)[^"]*"[^>]*>\s*##ig' -i "$f" || true

  # 2) Ensure /assets/nav-fix.css once (before </head>)
  perl -0777 -pe 's#\s*<link[^>]*href="/assets/nav-fix\.css"[^>]*/?>\s*##ig' -i "$f" || true
  if grep -qi '</head>' "$f"; then
    perl -0777 -pe 's#</head>#<link rel="stylesheet" href="/assets/nav-fix.css">\n</head>#i' -i "$f" || true
  else
    sed -i '1i\<link rel="stylesheet" href="/assets/nav-fix.css">' "$f" || true
  fi

  # 3) Add skip link once (right after <body>) if missing
  if ! grep -qi 'class="skip-to-content"' "$f"; then
    perl -0777 -pe 's{<body([^>]*)>}{<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>}i' -i "$f" || true
  fi

  # 4) Ensure <main id="main"> when main has no id
  perl -0777 -pe 's{<main(?![^>]*\bid=)[^>]*>}{ my $x=$&; $x=~s/<main/<main id="main"/i; $x }eig' -i "$f" || true

  # 5) Normalise “Reports” links to /reports/
  perl -0777 -pe 's{(<a\b[^>]*\bhref=")(?:/?reports(?:\.html)?/?)(")}{$1/reports/$2}ig' -i "$f" || true

  # 6) JSON-LD: add missing type="application/ld+json"
  perl -0777 -pe 's{<script\b(?![^>]*\btype=)([^>]*)>\s*({[\s\S]*?"@context"\s*:\s*"https?://schema\.org"[\s\S]*?})\s*</script>}{<script type="application/ld+json"$1>$2</script>}igs' -i "$f" || true

  # 7) Inject external runtimes once, before </body>
  perl -0777 -pe 's#\s*<script[^>]*src="/assets/nav-current\.js"[^>]*></script>\s*##ig' -i "$f" || true
  perl -0777 -pe 's#\s*<script[^>]*src="/assets/sw-register\.js"[^>]*></script>\s*##ig' -i "$f" || true
  if grep -qi '</body>' "$f"; then
    perl -0777 -pe 's#</body>#<script src="/assets/nav-current.js" defer></script>\n<script src="/assets/sw-register.js" defer></script>\n</body>#i' -i "$f" || true
  else
    printf '\n<script src="/assets/nav-current.js" defer></script>\n<script src="/assets/sw-register.js" defer></script>\n' >> "$f" || true
  fi
done

# 8) CSS patch: smaller spinner + nav polish (append once)
css="assets/nav-fix.css"; touch "$css"
if ! grep -q '/* RBIS SPINNER SIZE */' "$css" 2>/dev/null; then
  cat >> "$css" <<'CSS'
/* RBIS SPINNER SIZE */
.crest,.crest-spin{width:clamp(120px,28vw,220px);height:auto;max-width:100%}
@media (min-width:1024px){ .crest,.crest-spin{width:clamp(160px,20vw,260px)} }

/* NAV POLISH */
header nav ul{display:flex;gap:1rem;flex-wrap:wrap;align-items:center;margin:0;padding:0;list-style:none}
header nav ul a{display:inline-flex;padding:.5rem .8rem;border-radius:.5rem;text-decoration:none}
header nav ul a:hover{background:#f9fafb}
header nav ul a[aria-current="page"]{background:#F3F4F6}
summary::-webkit-details-marker{display:none}
.rbis-burger{font-size:0;min-width:44px;min-height:44px;display:inline-flex;align-items:center;justify-content:center}
.rbis-burger::before{content:"☰";font-size:22px;line-height:1}
CSS
fi

echo "✅ v4: Sanitise complete on ${#FILES[@]} files."
# Basic totals to help you eyeball success
echo -n "— nav-fix.css links: "; grep -RIn --include='*.html' '<link[^>]*href="/assets/nav-fix\.css"' . | wc -l || true
echo -n "— skip-to-content:  "; grep -RIn --include='*.html' 'class="skip-to-content"' . | wc -l || true
echo -n "— JSON-LD typed:    "; grep -RIn --include='*.html' '<script[^>]*application/ld\+json' . | wc -l || true
