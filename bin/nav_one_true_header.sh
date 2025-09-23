#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
HDR="assets/_site_header.html"

# Collect HTML files (skip _backups)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi
TMP=(); for f in "${FILES[@]}"; do [[ "$f" == */_backups/* ]] || TMP+=("$f"); done; FILES=("${TMP[@]}")

for f in "${FILES[@]}"; do
  # 1) Strip legacy nav/CSS/JS and hero-embedded nav
  perl -0777 -i -pe '
    s#<header\s+id="rbis-nav"[^>]*>.*?</header>\s*##gis;
    s#<header\s+class="site-header"[^>]*>.*?</header>\s*##gis;
    s#<link[^>]+href="/assets/nav-fix\.css"[^>]*>\s*##gis;
    s#<script[^>]+src="/assets/nav-current\.js"[^>]*>\s*</script>\s*##gis;
    s#<script[^>]+id="nav-current"[^>]*>.*?</script>\s*##gis;
    s#<nav[^>]*aria-label="Primary"[^>]*>\s*<a[^>]*class="brand"[^>]*>.*?</nav>\s*##gis;
  ' "$f"

  # 2) Ensure skip link
  grep -qi 'class="skip-to-content"' "$f" || \
    perl -0777 -i -pe 's#(<body\b[^>]*>)#$1\n<a class="skip-to-content" href="#main">Skip to content</a>#i' "$f"

  # 3) Insert one modern header after skip link else after <body>
  awk -v hdr="$HDR" '
    BEGIN{done=0}
    /<a[^>]*class="skip-to-content"[^>]*>/ && !done { print; while((getline L < hdr)>0) print L; close(hdr); done=1; next }
    /<body\b[^>]*>/ && !done { print; while((getline L < hdr)>0) print L; close(hdr); done=1; next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

  # 4) Guarantee <main id="main"> and close before footer
  perl -0777 -i -pe 's#<main(?![^>]*\bid=)#<main id="main"#ig' "$f"
  grep -qi '<main\b' "$f" || perl -0777 -i -pe 's#</header>#</header>\n<main id="main">#i' "$f"
  perl -0777 -i -pe 's#</footer>#</main>\n</footer>#i' "$f"
done

# Remove legacy CSS so it can’t repaint the old grey bars
rm -f assets/nav-fix.css || true

# Commit only if there are changes
if ! git diff --quiet; then
  git add -A
  git commit -m "fix(nav): remove legacy nav & enforce one modern header site-wide"
else
  echo "No changes to commit."
fi
