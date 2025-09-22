#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

echo "Hello from a long script!"
# OVERWRITE the script (exactly as below)
mkdir -p bin
cat > bin/site_cleanse.sh <<'BASH'
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# ---------- collect HTML files (skip _backups) ----------
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi
TMP=(); for f in "${FILES[@]}"; do [[ "$f" == */_backups/* ]] || TMP+=("$f"); done; FILES=("${TMP[@]}")

# ---------- assets: nav shadow helper ----------
mkdir -p assets
if [[ ! -f assets/nav-shadow.js ]]; then
  cat > assets/nav-shadow.js <<'JS'
(function(){const onScroll=()=>document.body.classList.toggle('scrolled',scrollY>6);onScroll();addEventListener('scroll',onScroll,{passive:true});})();
JS
fi

# ---------- assets: nav v2 css (scoped + skip-link styles) ----------
touch assets/site.v2.css
if ! grep -q '/* RBIS:NAVV2 */' assets/site.v2.css; then
  cat >> assets/site.v2.css <<'CSS'
/* RBIS:NAVV2 */
:root{--rbis-max:1120px;--rbis-gap:16px;--rbis-surface:rgba(255,255,255,.72);--rbis-border:rgba(0,0,0,.08);--rbis-text:#111}
@media (prefers-color-scheme:dark){:root{--rbis-surface:rgba(15,15,18,.7);--rbis-border:rgba(255,255,255,.1);--rbis-text:#f3f3f3}}
.site-header{position:sticky;top:0;z-index:1000;backdrop-filter:saturate(120%) blur(10px);background:var(--rbis-surface);border-bottom:1px solid var(--rbis-border)}
.site-header-inner{max-width:var(--rbis-max);margin:0 auto;padding:10px var(--rbis-gap);display:flex;align-items:center;gap:12px;justify-content:space-between}
.site-header .brand{font-weight:800;letter-spacing:.2px;text-decoration:none;color:var(--rbis-text)}
.site-header nav ul{list-style:none;margin:0;padding:0;display:flex;gap:14px;align-items:center}
.site-header nav a{text-decoration:none;color:var(--rbis-text)}
.rbis-burger{cursor:pointer}
.rbis-menu{display:none}
@media (max-width:880px){.rbis-menu{display:block}.site-header nav ul{display:none}.rbis-menu[open]+ul{display:flex;flex-direction:column;padding:10px 0}}
body.scrolled .site-header{box-shadow:0 6px 20px rgba(0,0,0,.08)}
.skip-to-content{position:absolute;left:-9999px;top:auto;width:1px;height:1px;overflow:hidden}
.skip-to-content:focus{position:fixed;left:16px;top:16px;width:auto;height:auto;padding:.5rem .75rem;background:#005fcc;color:#fff;border-radius:8px;outline:0;z-index:2000}
CSS
fi

# ensure the CSS is pulled in globally via rbis.css (idempotent)
if [[ -f assets/rbis.css ]] && ! grep -q 'site.v2.css' assets/rbis.css; then
  sed -i '1i @import url("/assets/site.v2.css");' assets/rbis.css || true
fi

# header block to inject
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

# ---------- per-file transforms ----------
for f in "${FILES[@]}"; do
  grep -qi '<body\b' "$f" || continue

  # 1) skip link (normalize or add)
  perl -0777 -i -pe 's/class="skip-to-content[^"]*"/class="skip-to-content"/gi' "$f"
  if ! perl -0777 -ne 'exit 0 if /<a\b[^>]*class="skip-to-content"/i; exit 1' "$f"; then
    perl -0777 -i -pe 's#(<body\b[^>]*>)#$1\n<a class="skip-to-content" href="#main">Skip to content</a>#i' "$f"
  fi

  # 2) remove old inline runtime if any
  perl -0777 -i -pe 's#<script id="nav-current">.*?</script>\s*##gis; s#<script id="sw-register">.*?</script>\s*##gis' "$f"

  # 3) insert professional header if missing
  if ! grep -qi 'class="site-header"' "$f"; then
    awk -v block="$HEADER" 'BEGIN{done=0}
      /<a[^>]*class="skip-to-content"[^>]*>/ && !done {print; print block; done=1; next}
      {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    if ! grep -qi 'class="site-header"' "$f"; then
      awk -v block="$HEADER" 'BEGIN{done=0}
        /<body\b[^>]*>/ && !done {print; print block; done=1; next}
        {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    fi
  fi

  # 4) ensure <main id="main">
  perl -0777 -i -pe 's#<main(?![^>]*\bid=)#<main id="main"#ig' "$f"
  if ! grep -qi '<main\b' "$f"; then
    awk 'BEGIN{done=0}
      /<\/header>/ && !done {print; print "<main id=\"main\">"; done=1; next}
      {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    if grep -qi '</footer>' "$f"; then
      perl -0777 -i -pe 's#</footer>#</main>\n</footer>#i' "$f"
    else
      perl -0777 -i -pe 's#</body>#</main>\n</body>#i' "$f"
    fi
  fi

  # 5) JSON-LD hygiene
  perl -0777 -i -pe 's#<script(?![^>]*\btype=)([^>]*)>\s*({[^<]*"@context"\s*:\s*"https?://schema\.org"[^<]*})\s*</script>#<script type="application/ld+json"$1>$2</script>#igs' "$f"
  perl -0777 -i -pe 's#(\>)(\s*)\{(?:(?!</script>).)*?"@context"\s*:\s*"https?://schema\.org"(?:(?!</script>).)*?\}(\s*)(\<)#$1$2$3$4#gis' "$f"
  if ! grep -qi '<script[^>]*application/ld\+json' "$f"; then
    CANONICAL="$(grep -oiE '<link[^>]+rel=["'\'']canonical["'\''][^>]+href=["'\''][^"'\'' ]+' "$f" | sed -E 's/.*href=["'"'"']([^"'"'"']+).*/\1/i' | head -n1 || true)"
    if [[ -z "$CANONICAL" ]]; then
      P="${f#./}"; URL="https://www.rbisintelligence.com/$P"; URL="${URL%index.html}"
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

  # 6) link the scroll-shadow helper
  if ! grep -q '/assets/nav-shadow\.js' "$f"; then
    perl -0777 -i -pe 's#</body>#  <script src="/assets/nav-shadow.js" defer></script>\n</body>#i' "$f"
  fi

  # 7) close a tag if immediately followed by a script (rare stray)
  perl -0777 -i -pe 's#(<a\b[^>]*>[^<]*)(\s*<script\b)#$1</a>\n$2#gi' "$f"

  # 8) avoid duplicate closing html
  perl -0777 -i -pe '1 while s#</html>.*</html>#</html>#is' "$f"
done

# ---------- summary ----------
echo "—— Cleanse complete ——"
echo -n "Pages:              "; printf '%s\n' "${#FILES[@]}"
echo -n "site-header:        "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="site-header"' . | wc -l
echo -n "skip links:         "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="skip-to-content"' . | wc -l
echo -n "<main id=main>:     "; grep -RIl --include='*.html' --exclude-dir='_backups' '<main id="main"' . | wc -l
echo -n "typed JSON-LD:      "; grep -RIl --include='*.html' --exclude-dir='_backups' 'application/ld\+json' . | wc -l
echo -n "nav-shadow linked:  "; grep -RIl --include='*.html' --exclude-dir='_backups' '/assets/nav-shadow\.js' . | wc -l
BASH

chmod +x bin/site_cleanse.sh
bash bin/site_cleanse.sh

git add -A
git commit -m "chore(cleanse): apply professional nav, skip link + main, JSON-LD hygiene, scroll shadow"
git push

# quick verify
echo -n "site-header present: "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="site-header"' . | wc -l
echo -n "skip links:          "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="skip-to-content"' . | wc -l
echo -n "<main id=main>:      "; grep -RIl --include='*.html' --exclude-dir='_backups' '<main id="main"' . | wc -l
echo -n "typed JSON-LD:       "; grep -RIl --include='*.html' --exclude-dir='_backups' 'application/ld\+json' . | wc -l

