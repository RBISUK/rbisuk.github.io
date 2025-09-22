#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# Collect HTML files (skip _backups)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi
TMP=(); for f in "${FILES[@]}"; do [[ "$f" == */_backups/* ]] || TMP+=("$f"); done; FILES=("${TMP[@]}")

# Ensure the tiny scroll-shadow helper exists
mkdir -p assets
if [[ ! -f assets/nav-shadow.js ]]; then
  cat > assets/nav-shadow.js <<'JS'
(function(){const onScroll=()=>document.body.classList.toggle('scrolled',scrollY>6);onScroll();addEventListener('scroll',onScroll,{passive:true});})();
JS
fi

# Canonical nav markup
read -r -d '' NAV <<"HTML"
<header class="site-header">
  <nav aria-label="Primary"><a class="brand" href="/index.html">RBIS</a><details class="rbis-menu" role="navigation"><summary class="rbis-burger" aria-label="Menu">Menu</summary>
  <ul>
    <li><a href="/solutions.html">Solutions</a></li>
    <li><a href="/reports/">Reports</a></li>
    <li><a href="/products.html">Products</a></li>
    <li><a href="/about.html">About</a></li>
    <li><a href="/contact.html">Contact</a></li>
  </ul>
  </details></nav>
</header>
HTML

for f in "${FILES[@]}"; do
  # only full pages
  grep -qi '<body\b' "$f" || continue

  # Remove placeholder header and inline scripts
  perl -0777 -i -pe 's#<header\s+id="rbis-nav"\s*></header>\s*##gis' "$f"
  perl -0777 -i -pe 's#<script id="nav-current">.*?</script>\s*##gis; s#<script id="sw-register">.*?</script>\s*##gis' "$f"

  # Ensure /assets/rbis.css linked (it imports site.v2.css)
  grep -qi '/assets/rbis\.css' "$f" || \
    perl -0777 -i -pe 's#</head>#  <link rel="stylesheet" href="/assets/rbis.css">\n</head>#i' "$f"

  # Add skip link after <body> if missing
  if ! grep -qi 'class="skip-to-content"' "$f"; then
    perl -0777 -i -pe 's#(<body\b[^>]*>)#$1\n<a class="skip-to-content" href="#main">Skip to content</a>#i' "$f"
  fi

  # Insert the header right after the skip link (once)
  if ! grep -qi 'class="site-header"' "$f"; then
    awk -v nav="$NAV" 'BEGIN{added=0}
      {
        print
        if(!added && /class="skip-to-content"/){ print nav; added=1 }
      }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi

  # Normalize skip link class (remove doubled suffixes)
  perl -0777 -i -pe 's/class="skip-to-content[^"]*"/class="skip-to-content"/gi' "$f"

  # Ensure <main id="main">
  perl -0777 -i -pe 's#<main(?![^>]*\bid=)#<main id="main"#ig' "$f"

  # Ensure nav-shadow helper linked once before </body>
  grep -q '/assets/nav-shadow\.js' "$f" || \
    perl -0777 -i -pe 's#</body>#  <script src="/assets/nav-shadow.js" defer></script>\n</body>#i' "$f"
done

# Summary
echo "—— Summary ——"
echo -n "Header present: "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="site-header"' . | wc -l
echo -n "Skip link:      "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="skip-to-content"' . | wc -l
echo -n "<main id=main>: "; grep -RIl --include='*.html' --exclude-dir='_backups' '<main id="main"' . | wc -l
echo -n "nav-shadow:     "; grep -RIl --include='*.html' --exclude-dir='_backups' '/assets/nav-shadow\.js' . | wc -l
