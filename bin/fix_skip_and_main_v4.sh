#!/usr/bin/env bash
# Ensure skip link + <main id="main"> on every full HTML page (safe & idempotent).

set -Eeuo pipefail; IFS=$'\n\t'

# Collect HTML files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

for f in "${FILES[@]}"; do
  # Only operate on complete pages
  grep -qi '<body\b' "$f" || continue

  # A) Normalise legacy skip class -> skip-to-content
  perl -0777 -i -pe 's{(<a[^>]+class=(["\x27]))([^"'\''>]*\b)skip\b([^"'\''>]*)(\2)}{$1$3skip-to-content$4$5}ig' "$f" || true

  # B) Ensure a skip link exists right after <body>
  perl -0777 -i -pe '
    unless (m{<a[^>]+\bclass=(["\x27])[^"\x27]*\bskip-to-content\b}i) {
      s{(<body\b[^>]*>)}{$1\n  <a class="skip-to-content" href="#main">Skip to content</a>}i;
    }' "$f" || true

  # C) Ensure a <main id="main"> exists
  if grep -qi '<main\b' "$f"; then
    # Add id if missing
    perl -0777 -i -pe 's{<main(?![^>]*\bid=)([^>]*)>}{<main id="main"$1>}i' "$f" || true
    # Standardise non-"main" ids to id="main"
    perl -0777 -i -pe 's{<main([^>]*?)\bid=(["\x27])(?!main)[^"\x27]*\2([^>]*)>}{<main$1 id="main"$3>}i' "$f" || true
  else
    # No <main> at all → wrap entire body content
    perl -0777 -i -pe 's{(<body\b[^>]*>)}{$1\n<main id="main">}i; s{</body>}{</main>\n</body>}i' "$f" || true
  fi
done

echo "✅ skip link + <main id=\"main\"> ensured on ${#FILES[@]} files."
