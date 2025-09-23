#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

HDR="assets/_site_header.html"
[ -s "$HDR" ] || { echo "Missing $HDR"; exit 1; }

# Collect HTML files (skip _backups)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi
TMP=(); for f in "${FILES[@]}"; do [[ "$f" == */_backups/* ]] || TMP+=("$f"); done; FILES=("${TMP[@]}")
for f in "${FILES[@]}"; do
  # 1) Strip ALL legacy nav variants and old assets
  perl -0777 -i -pe '
    s#<header\s+id="rbis-nav"[^>]*>.*?</header>\s*##gis;
    s#<header\s+class="site-header"[^>]*>.*?</header>\s*##gis;         # remove any existing headers (we re-insert one)
    s#<link[^>]+href="/assets/nav-fix\.css"[^>]*>\s*##gis;              # old grey bar CSS
    s#<script[^>]+src="/assets/nav-current\.js"[^>]*>\s*</script>\s*##gis;
    s#<script[^>]+id="nav-current"[^>]*>.*?</script>\s*##gis;           # inline injector
    s#<nav[^>]*aria-label="Primary"[^>]*>\s*<a[^>]*class="brand"[^>]*>.*?</nav>\s*##gis; # hero-embedded nav
  ' "$f"

  # 2) Normalize/add the skip link right after <body>
  perl -0777 -i -pe 's/class="skip-to-content[^"]*"/class="skip-to-content"/gi' "$f"
  perl -0777 -ne 'exit 0 if /<a\b[^>]*class="skip-to-content"/i; exit 1' "$f" || \
    perl -0777 -i -pe 's#(<body\b[^>]*>)#$1\n<a class="skip-to-content" href="#main">Skip to content</a>#i' "$f"

  # 3) Insert the one true header after the skip link (fallback: after <body>)
  awk -v hdr="$HDR" 'BEGIN{done=0}
    /<a[^>]*class="skip-to-content"[^>]*>/ && !done { print; while ((getline L < hdr)>0) print L; close(hdr); done=1; next }
    /<body\b[^>]*>/ && !done { print; while ((getline L < hdr)>0) print L; close(hdr); done=1; next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

  # 4) Ensure <main id="main"> exists and closes before footer/body
  perl -0777 -i -pe 's#<main(?![^>]*\bid=)#<main id="main"#ig' "$f"
  perl -0777 -ne 'exit 0 if /<main\b/i; exit 1' "$f" || \
    perl -0777 -i -pe 's#</header>#</header>\n<main id="main">#i' "$f"
  perl -0777 -i -pe 's#</footer>#</main>\n</footer>#i; s#</body>#</main>\n</body>#i' "$f"

  # 5) Link the scroll shadow helper once
  grep -q '/assets/nav-shadow\.js' "$f" || \
    perl -0777 -i -pe 's#</body>#  <script src="/assets/nav-shadow.js" defer></script>\n</body>#i' "$f"

  # 6) Fix rare stray <a> immediately followed by <script>
  perl -0777 -i -pe 's#(<a\b[^>]*>[^<]*)(\s*<script\b)#$1</a>\n$2#gi' "$f"

  # 7) De-duplicate closing tags
  perl -0777 -i -pe '1 while s#</html>.*</html>#</html>#is; 1 while s#</body>.*</body>#</body>#is' "$f"
done

# Remove legacy CSS file so it can’t reapply styles
rm -f assets/nav-fix.css || true

echo "Stage 2 applied."
