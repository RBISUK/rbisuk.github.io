#!/usr/bin/env bash
# Tidy <head> and nav across all *.html files (safe + idempotent)

set -Eeuo pipefail; IFS=$'\n\t'

# Collect site pages
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

for f in "${FILES[@]}"; do
  # 1) Remove malformed preconnects (href not starting http/https)
  perl -0777 -pe '
    s#\s*<link\b(?=[^>]*\brel="[^"]*\bpreconnect\b)[^>]*\bhref="(?!https?://)[^"]*"[^>]*>\s*##ig;
  ' -i "$f" || true

  # 2) Clean <link rel>: drop noopener/noreferrer from LINK (they are for <a>)
  perl -0777 -pe '
    s{(<link\b[^>]*\brel=")([^"]*)(")}{
      my($a,$rel,$z)=($1,$2,$3);
      my %seen; my @t = grep { $_ && !$seen{$_}++ && $_ ne "noopener" && $_ ne "noreferrer" } split(/\s+/,$rel);
      $a.(join " ", @t).$z
    }ige;
  ' -i "$f" || true

  # 3) Ensure /assets/nav-fix.css is present exactly once before </head>
  perl -0777 -pe 's#\s*<link[^>]*href="/assets/nav-fix\.css"[^>]*/?>\s*##ig' -i "$f" || true
  perl -0777 -pe 's#</head>#<link rel="stylesheet" href="/assets/nav-fix.css">\n</head>#i' -i "$f" || true

  # 4) Normalise skip link: remove old wrong one, insert standard after <body>
  perl -0777 -pe 's#\s*<a\b[^>]*id="skip-to-content"[^>]*>.*?</a>\s*##isg' -i "$f" || true
  perl -0777 -pe 's#\s*<a\b[^>]*class="skip-to-content"[^>]*>.*?</a>\s*##isg' -i "$f" || true
  perl -0777 -pe 's#<body([^>]*)>#<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>#i' -i "$f" || true

  # 5) Ensure <main id="main"> if missing
  perl -0777 -pe '
    s#<main(?![^>]*\bid=)[^>]*># my $x=$&; $x=~s/<main/<main id="main"/i; $x #eig;
  ' -i "$f" || true

  # 6) Normalise anchor links to /reports/
  perl -0777 -pe '
    s{(<a\b[^>]*\bhref=")/(?:reports(?:\.html)?)(")}{$1/reports/$2}ig;
    s{(<a\b[^>]*\bhref=")reports(?:\.html)?(")}{$1/reports/$2}ig;
  ' -i "$f" || true

  # 7) Deduplicate og:* and twitter:* metas (keep first)
  perl -0777 -pe '
    my %seen;
    s{<meta\s+(?:property|name)="(og:[^"]+|twitter:[^"]+)"[^>]*>\s*}{
      $seen{$1}++ ? "" : $&
    }ige;
  ' -i "$f" || true

  # 8) JSON-LD: add missing type if the block looks like schema JSON
  perl -0777 -pe '
    s{<script\b(?![^>]*\btype=)([^>]*)>\s*(\{\s*"@context"[\s\S]*?\})\s*</script>}
     {<script type="application/ld+json"$1>$2</script>}igs;
  ' -i "$f" || true

  # 9) Move/standardise nav-current + sw-register (remove anywhere, add before </body>)
  perl -0777 -pe 's#\s*<script\b[^>]*id="nav-current"[^>]*>[\s\S]*?</script>\s*##ig' -i "$f" || true
  perl -0777 -pe 's#\s*<script\b[^>]*id="sw-register"[^>]*>[\s\S]*?</script>\s*##ig' -i "$f" || true
  perl -0777 -pe '
    s#</body>#<script id="nav-current">(()=>{try{
      const p=(location.pathname||"/").replace(/index\.html?$/,"").replace(/\/+$/,"/")||"/";
      document.querySelectorAll("nav a[href]").forEach(a=>{
        const href=(a.getAttribute("href")||"").replace(/index\.html?$/,"");
        if(href===p || href.replace(/\/$/,"")===p.replace(/\/$/,"")) a.setAttribute("aria-current","page");
      });
    }catch{}})();</script>
<script id="sw-register">if("serviceWorker"in navigator){window.addEventListener("load",()=>{navigator.serviceWorker.register("/sw.js").catch(()=>{});});}</script>
</body>#i
  ' -i "$f" || true
done

# 10) Ensure CSS patch exists for spinner/nav sizing (idempotent)
mkdir -p assets
css="assets/nav-fix.css"; touch "$css"
if ! grep -q '/* RBIS SPINNER SIZE */' "$css" 2>/dev/null; then
  cat >> "$css" <<'CSS'
/* RBIS SPINNER SIZE */
.crest,.crest-spin{width:clamp(140px,35vw,260px);height:auto;max-width:100%}
@media (min-width:1024px){ .crest,.crest-spin{width:clamp(180px,22vw,300px)} }
/* RBIS NAV TIDY */
header nav ul{display:flex;gap:1rem;flex-wrap:wrap;align-items:center}
header nav ul a{display:inline-flex;padding:.5rem .8rem;border-radius:.5rem}
header nav ul a[aria-current="page"]{background:#F3F4F6}
summary::-webkit-details-marker{display:none}
.rbis-burger{font-size:0;min-width:44px;min-height:44px;display:inline-flex;align-items:center;justify-content:center}
.rbis-burger::before{content:"☰";font-size:22px;line-height:1}
CSS
fi

echo "✅ Sanitise complete on ${#FILES[@]} files."
