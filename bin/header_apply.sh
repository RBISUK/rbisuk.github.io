#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
HDR="assets/_site_header.html"

mapfile -d '' -t FILES < <(git ls-files -z '*.html')

for f in "${FILES[@]}"; do
  # remove any existing site-header (avoid duplicates)
  perl -0777 -i -pe 's#<header\s+class="site-header"[^>]*>.*?</header>\s*##gis' "$f"

  # normalize/add skip link
  perl -0777 -i -pe 's/class="skip-to-content[^"]*"/class="skip-to-content"/gi' "$f"
  grep -qi 'class="skip-to-content"' "$f" || \
    perl -0777 -i -pe 's#(<body\b[^>]*>)#$1\n<a class="skip-to-content" href="#main">Skip to content</a>#i' "$f"

  # insert header after skip link else right after <body>
  awk -v hdr="$HDR" '
    BEGIN{done=0}
    /<a[^>]*class="skip-to-content"[^>]*>/ && !done { print; while((getline L < hdr)>0) print L; close(hdr); done=1; next }
    /<body\b[^>]*>/ && !done { print; while((getline L < hdr)>0) print L; close(hdr); done=1; next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

  # ensure <main id="main"> exists and closes before footer
  perl -0777 -i -pe 's#<main(?![^>]*\bid=)#<main id="main"#ig' "$f"
  grep -qi '<main\b' "$f" || perl -0777 -i -pe 's#</header>#</header>\n<main id="main">#i' "$f"
  perl -0777 -i -pe 's#</footer>#</main>\n</footer>#i' "$f"
done
