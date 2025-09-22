#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$PWD"

# ---------- Gather HTML files (skip backups) ----------
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi
TMP=(); for f in "${FILES[@]}"; do [[ "$f" == */_backups/* ]] || TMP+=("$f"); done; FILES=("${TMP[@]}")

# ---------- Assets: nav shadow JS ----------
mkdir -p assets
if [[ ! -f assets/nav-shadow.js ]]; then
  cat > assets/nav-shadow.js <<'JS'
(function(){
  const onScroll=()=>document.body.classList.toggle('scrolled',scrollY>6);
  onScroll(); addEventListener('scroll',onScroll,{passive:true});
})();
JS
fi

# ---------- Assets: nav v2 CSS (only once; very scoped) ----------
mkdir -p assets
touch assets/site.v2.css
if ! grep -q '/* RBIS:NAVV2 */' assets/site.v2.css; then
  cat >> assets/site.v2.css <<'CSS'
/* RBIS:NAVV2 */
:root{
  --rbis-max:1120px; --rbis-gap:16px;
  --rbis-surface:rgba(255,255,255,.72);
  --rbis-border:rgba(0,0,0,.08);
  --rbis-text:#111;
}
@media (prefers-color-scheme:dark){
  :root{ --rbis-surface:rgba(15,15,18,.7); --rbis-border:rgba(255,255,255,.1); --rbis-text:#f3f3f3; }
}
.site-header{ position:sticky; top:0; z-index:1000; backdrop-filter:saturate(120%) blur(10px);
  background:var(--rbis-surface); border-bottom:1px solid var(--rbis-border); }
.site-header-inner{ max-width:var(--rbis-max); margin:0 auto; padding:10px var(--rbis-gap);
  display:flex; align-items:center; gap:12px; justify-content:space-between; }
.site-header .brand{ font-weight:800; letter-spacing:.2px; text-decoration:none; color:var(--rbis-text); }
.site-header nav ul{ list-style:none; margin:0; padding:0; display:flex; gap:14px; align-items:center; }
.site-header nav a{ text-decoration:none; color:var(--rbis-text); }
.rbis-burger{ cursor:pointer; }
.rbis-menu{ display:none; }
@media (max-width: 880px){
  .rbis-menu{ display:block; }
  .site-header nav ul{ display:none; }
  .rbis-menu[open] + ul{ display:flex; flex-direction:column; padding:10px 0; }
}
/* subtle shadow when scrolled */
body.scrolled .site-header{ box-shadow:0 6px 20px rgba(0,0,0,.08); }
/* skip link baseline */
.skip-to-content{ position:absolute; left:-9999px; top:auto; width:1px; height:1px; overflow:hidden; }
.skip-to-content:focus{ position:fixed; left:16px; top:16px; width:auto; height:auto; padding:.5rem .75rem;
  background:#005fcc; color:white; border-radius:8px; outline:0; z-index:2000; }
CSS
fi

# Ensure /assets/site.v2.css is loaded globally via rbis.css (idempotent)
if [[ -f assets/rbis.css ]] && ! grep -q 'site.v2.css' assets/rbis.css; then
  sed -i '1i @import url("/assets/site.v2.css");' assets/rbis.css || true
fi

# ---------- Header markup we inject when missing ----------
read -r -d '' HEADER <<'HTML'
<header class="site-header" role="banner" aria-label="Site header">
  <div class="site-header-inner">
    <a class="brand" href="/index.html">RBIS</a>
    <nav aria-label="Primary">
      <details class="rbis-menu">
        <summary class="rbis-burger" aria-label="Menu">Menu</summary>
      </details>
      <ul>
        <li><a href="/solutions.html">Solutions</a></li>
        <li><a href="/reports/">Reports</a></li>
        <li><a href="/products.html">Products</a></li>
        <li><a href="/about.html">About</a></li>
        <li><a href="/contact.html">Contact</a></li>
      </ul>
    </nav>
  </div>
</header>
HTML
export HEADER

# ---------- Per-file transforms ----------
for f in "${FILES[@]}"; do
  # only full pages
  grep -qi '<body\b' "$f" || continue

  # 1) Normalise/ensure skip link
  perl -0777 -i -pe 's/class="skip-to-content[^"]*"/class="skip-to-content"/gi' "$f"
  if ! perl -0777 -ne 'exit 0 if /<a\b[^>]*class="skip-to-content"/i; exit 1' "$f"; then
    perl -0777 -i -pe 's#(<body\b[^>]*>)#$1\n<a class="skip-to-content" href="#main">Skip to content</a>#i' "$f"
  fi

  # 2) Remove deprecated inline runtime (if any remain)
  perl -0777 -i -pe 's#<script id="nav-current">.*?</script>\s*##gis; s#<script id="sw-register">.*?</script>\s*##gis' "$f"

  # 3) Insert professional header if missing
  if ! grep -qi 'class="site-header"' "$f"; then
    # Prefer after skip link; else directly after <body>
    awk -v block="$HEADER" 'BEGIN{done=0}
      /<a[^>]*class="skip-to-content"[^>]*>/ && !done {print; print block; done=1; next}
      {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    if ! grep -qi 'class="site-header"' "$f"; then
      awk -v block="$HEADER" 'BEGIN{done=0}
        /<body\b[^>]*>/ && !done {print; print block; done=1; next}
        {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    fi
  fi

  # 4) Ensure <main id="main">
  # 4a) add id if <main> exists without id
  perl -0777 -i -pe 's#<main(?![^>]*\bid=)#<main id="main"#ig' "$f"
  # 4b) if no <main> at all, inject an opening after header and a closing before </footer> or </body>
  if ! grep -qi '<main\b' "$f"; then
    # open
    awk 'BEGIN{done=0}
      /<\/header>/ && !done {print; print "<main id=\"main\">"; done=1; next}
      {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    # close before footer or body
    if grep -qi '</footer>' "$f"; then
      perl -0777 -i -pe 's#</footer>#</main>\n</footer>#i' "$f"
    else
      perl -0777 -i -pe 's#</body>#</main>\n</body>#i' "$f"
    fi
  fi

  # 5) JSON-LD hygiene
  # 5a) Any JSON-LD <script> without type? add it.
  perl -0777 -i -pe 's#<script(?![^>]*\btype=)([^>]*)>\s*({[^<]*"@context"\s*:\s*"https?://schema\.org"[^<]*})\s*</script>#<script type="application/ld+json"$1>$2</script>#igs' "$f"
  # 5b) Remove raw JSON-LD objects not inside <script>
  perl -0777 -i -pe 's#(\>)(\s*)\{(?:(?!</script>).)*?"@context"\s*:\s*"https?://schema\.org"(?:(?!</script>).)*?\}(\s*)(\<)#$1$2$3$4#gis' "$f"
  # 5c) If page has no typed JSON-LD at all, inject minimal WebPage JSON-LD using canonical or derived URL
  if ! grep -qi '<script[^>]*application/ld\+json' "$f"; then
    CANONICAL="$(grep -oiE '<link[^>]+rel=["'\'']canonical["'\''][^>]+href=["'\''][^"'\'' ]+' "$f" | sed -E 's/.*href=["'"'"']([^"'"'"']+).*/\1/i' | head -n1 || true)"
    if [[ -z "$CANONICAL" ]]; then
      # derive from path
      P="${f#./}"
      URL="https://www.rbisintelligence.com/$P"
      URL="${URL%index.html}"
    else
      URL="$CANONICAL"
    fi
    awk -v u="$URL" 'BEGIN{done=0}
      /<\/head>/ && !done {
        print "  <script id=\"ld-webpage\" type=\"application/ld+json\">"
        print "  {\"@context\":\"https://schema.org\",\"@type\":\"WebPage\",\"url\":\"" u "\"}"
        print "  </script>"
        done=1
      }
      {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi

  # 6) Link the scroll-shadow helper (once)
  if ! grep -q '/assets/nav-shadow\.js' "$f"; then
    perl -0777 -i -pe 's#</body>#  <script src="/assets/nav-shadow.js" defer></script>\n</body>#i' "$f"
  fi

  # 7) Close stray <a> that is immediately followed by a <script>
  perl -0777 -i -pe 's#(<a\b[^>]*>[^<]*)(\s*<script\b)#$1</a>\n$2#gi' "$f"

  # 8) Ensure we don’t have duplicate </html> blocks
  perl -0777 -i -pe '1 while s#</html>.*</html>#</html>#is' "$f"
done

# ---------- Summary ----------
echo "—— Cleanse complete ——"
echo -n "Pages processed:  "; printf '%s\n' "${#FILES[@]}"
echo -n "site-header:      "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="site-header"' . | wc -l
echo -n "skip links:       "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="skip-to-content"' . | wc -l
echo -n "<main id=main>:   "; grep -RIl --include='*.html' --exclude-dir='_backups' '<main id="main"' . | wc -l
echo -n "typed JSON-LD:    "; grep -RIl --include='*.html' --exclude-dir='_backups' 'application/ld\+json' . | wc -l
echo -n "nav-shadow linked:"; grep -RIl --include='*.html' --exclude-dir='_backups' '/assets/nav-shadow\.js' . | wc -l
