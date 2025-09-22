#!/usr/bin/env bash
# v3 — safe/idempotent head + nav tidy for all *.html

set -Eeuo pipefail; IFS=$'\n\t'

# Collect pages
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

for f in "${FILES[@]}"; do
  # 1) Kill malformed preconnects like href="index.html:https://…"
  perl -0777 -pe 's#\s*<link\b(?=[^>]*\brel="[^"]*\bpreconnect\b)[^>]*\bhref="(?!https?://)[^"]*"[^>]*>\s*##ig' -i "$f" || true

  # 2) Drop noopener/noreferrer from <link rel> (only for anchors)
  perl -0777 -pe 's{(<link\b[^>]*\brel=")([^"]*)(")}{
    my($a,$r,$z)=($1,$2,$3); my %s;
    my @t=grep{$_ && !$s{$_}++ && $_ ne "noopener" && $_ ne "noreferrer"} split(/\s+/,$r);
    $a.(join " ",@t).$z
  }ige' -i "$f" || true

  # 3) Ensure /assets/nav-fix.css once (fallback if </head> missing)
  perl -0777 -pe 's#\s*<link[^>]*href="/assets/nav-fix\.css"[^>]*/?>\s*##ig' -i "$f" || true
  if grep -qi '</head>' "$f"; then
    perl -0777 -pe 's#</head>#<link rel="stylesheet" href="/assets/nav-fix.css">\n</head>#i' -i "$f" || true
  else
    sed -i '1i\<link rel="stylesheet" href="/assets/nav-fix.css">' "$f" || true
  fi

  # 4) Standard skip link (after <body>, else before first <main>)
  perl -0777 -pe 's#\s*<a\b[^>]*class="skip-to-content"[^>]*>.*?</a>\s*##isg' -i "$f" || true
  if grep -qi '<body' "$f"; then
    perl -0777 -pe 's#<body([^>]*)>#<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>#i' -i "$f" || true
  else
    perl -0777 -pe 's#<main#<a class="skip-to-content" href="#main">Skip to content</a>\n<main#i' -i "$f" || true
  fi

  # 5) Ensure <main id="main"> when missing
  perl -0777 -pe 's#<main(?![^>]*\bid=)[^>]*># my $x=$&; $x=~s/<main/<main id="main"/i; $x #eig' -i "$f" || true

  # 6) Normalise Reports links to /reports/
  perl -0777 -pe 's{(<a\b[^>]*\bhref=")/?reports(?:\.html)?(")}{$1/reports/$2}ig' -i "$f" || true

  # 7) JSON-LD — add type if missing
  perl -0777 -pe 's{<script\b(?![^>]*\btype=)([^>]*)>\s*(\{\s*"@context"[\s\S]*?\})\s*</script>}
                   {<script type="application/ld+json"$1>$2</script>}igs' -i "$f" || true

  # 8) Relocate nav-current & sw-register just before </body>
  perl -0777 -pe 's#\s*<script\b[^>]*id="nav-current"[^>]*>[\s\S]*?</script>\s*##ig' -i "$f" || true
  perl -0777 -pe 's#\s*<script\b[^>]*id="sw-register"[^>]*>[\s\S]*?</script>\s*##ig' -i "$f" || true
  if grep -qi '</body>' "$f"; then
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
  fi
done

# 9) CSS patch for spinner size + nav polish (append once)
mkdir -p assets
css="assets/nav-fix.css"; touch "$css"
if ! grep -q '/* RBIS SPINNER SIZE */' "$css" 2>/dev/null; then
  cat >> "$css" <<'CSS'
/* RBIS SPINNER SIZE */
.crest,.crest-spin{width:clamp(120px,28vw,220px);height:auto;max-width:100%}
@media (min-width:1024px){ .crest,.crest-spin{width:clamp(160px,20vw,260px)} }
/* RBIS NAV TIDY */
header nav ul{display:flex;gap:1rem;flex-wrap:wrap;align-items:center;margin:0;padding:0;list-style:none}
header nav ul a{display:inline-flex;padding:.5rem .8rem;border-radius:.5rem;text-decoration:none}
header nav ul a:hover{background:#f9fafb}
header nav ul a[aria-current="page"]{background:#F3F4F6}
summary::-webkit-details-marker{display:none}
.rbis-burger{font-size:0;min-width:44px;min-height:44px;display:inline-flex;align-items:center;justify-content:center}
.rbis-burger::before{content:"☰";font-size:22px;line-height:1}
CSS
fi

echo "✅ v3: Sanitise complete on ${#FILES[@]} files."
