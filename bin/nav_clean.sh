#!/usr/bin/env bash
set -euo pipefail
mapfile -d '' -t F < <(git ls-files -z '*.html')

for f in "${F[@]}"; do
  # remove old headers/css/js and hero-embedded nav
  perl -0777 -i -pe '
    s#<header\s+id="rbis-nav"[^>]*>.*?</header>\s*##gis;
    s#<header\s+class="site-header"[^>]*>.*?</header>\s*##gis;
    s#<link[^>]+href="/assets/nav-fix\.css"[^>]*>\s*##gis;
    s#<script[^>]+src="/assets/nav-current\.js"[^>]*>\s*</script>\s*##gis;
    s#<script[^>]+id="nav-current"[^>]*>.*?</script>\s*##gis;
    s#<nav[^>]*aria-label="Primary"[^>]*>\s*<a[^>]*class="brand"[^>]*>.*?</nav>\s*##gis;
  ' "$f"

  # ensure skip link
  grep -qi 'class="skip-to-content"' "$f" || \
    perl -0777 -i -pe 's#(<body\b[^>]*>)#$1\n<a class="skip-to-content" href="#main">Skip to content</a>#i' "$f"

  # insert the one true header after skip link (else after <body>)
  awk -v hdr="assets/_site_header.html" '
    BEGIN{d=0}
    /class="skip-to-content"/ && !d {print; while((getline L < hdr)>0) print L; close(hdr); d=1; next}
    /<body[^>]*>/ && !d          {print; while((getline L < hdr)>0) print L; close(hdr); d=1; next}
    {print}
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

  # guarantee <main id="main"> and close before footer
  perl -0777 -i -pe 's#<main(?![^>]*\bid=)#<main id="main"#ig' "$f"
  grep -qi '<main\b' "$f" || perl -0777 -i -pe 's#</header>#</header>\n<main id="main">#i' "$f"
  perl -0777 -i -pe 's#</footer>#</main>\n</footer>#i' "$f"
done

rm -f assets/nav-fix.css || true
git add -A && (git diff --cached --quiet || git commit -m "fix(nav): one clean header")
