#!/usr/bin/env bash
# Ensure <a class="skip-to-content" …> and <main id="main"> exist on full pages.
# Idempotent. Skips backups and report a11y mirrors.

set -Eeuo pipefail; IFS=$'\n\t'

# Collect HTML files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

for f in "${FILES[@]}"; do
  # Skip backups and mirrors
  case "$f" in
    _backups/*|*/_backups/*|reports/a11y/*|*/reports/a11y/*) continue;;
  esac

  # Only full pages
  grep -qi '<body\b' "$f" || continue

  # A) Normalise any class="skip" -> skip-to-content (handles multi-class, ' or ")
  perl -0777 -i -pe '
    s{\bclass=(["\'])([^"\']*?)\bskip\b([^"\']*)\1}{class=$1$2skip-to-content$3$1}ig;
  ' "$f" || true

  # B) Ensure a skip link exists right after <body>
  perl -0777 -i -pe '
    if (! /class=(["\'])[^\1]*\bskip-to-content\b/i) {
      s{(<body\b[^>]*>)}{$1\n  <a class="skip-to-content" href="#main">Skip to content</a>}i;
    }
  ' "$f" || true

  # C) Ensure a proper <main id="main">
  if grep -qi '<main\b' "$f"; then
    # If id missing, add it
    perl -0777 -i -pe 's{<main(?![^>]*\bid=)([^>]*)>}{<main id="main"$1>}i' "$f" || true
    # If id present but not "main", standardise
    perl -0777 -i -pe 's{<main([^>]*?)\bid=(["\'])(?!main\b)[^"\']*\2([^>]*)>}{<main$1 id="main"$3>}i' "$f" || true
  else
    # No <main>: insert after <body> (or after skip link if present), and close before </body>
    perl -0777 -i -pe '
      unless (/<main\b/i) {
        s{(<body\b[^>]*>\s*(?:<a[^>]*\bskip-to-content\b[^>]*>\s*)?)}{$1<main id="main">}i;
        s{</body>}{</main>\n</body>}i;
      }
    ' "$f" || true
  fi
done

echo "✅ skip link + <main id=\"main\"> ensured."
