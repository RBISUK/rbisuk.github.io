#!/usr/bin/env bash
# Ensure there's a skip link + <main id="main"> on every HTML page.
# Safe/idempotent. Skips files without a <body> (likely partials).

set -Eeuo pipefail; IFS=$'\n\t'

# Collect HTML files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

for f in "${FILES[@]}"; do
  # Only operate on full pages
  if ! grep -qi '<body\b' "$f"; then
    continue
  fi

  # 1) Add skip link right after <body> if missing
  if ! grep -qiE 'class=("|\x27)skip-to-content\1' "$f"; then
    perl -0777 -i -pe 's#(<body\b[^>]*>)#${1}\n<a class="skip-to-content" href="#main">Skip to content</a>#i' "$f" || true
  fi

  # 2) If there is a <main>:
  if grep -qi '<main\b' "$f"; then
    # 2a) Add id if missing
    perl -0777 -i -pe 's#<main(?![^>]*\bid=)([^>]*)>#<main id="main"$1>#i' "$f" || true
    # 2b) Standardise non-"main" ids to id="main"
    perl -0777 -i -pe 's#<main([^>]*?)\bid="(?!main")[^"]*"([^>]*)>#<main$1 id="main"$2>#i' "$f" || true
  else
    # 3) No <main> at all → wrap body content
    if grep -qiE 'class=("|\x27)skip-to-content\1' "$f"; then
      # Open right after the skip link we just ensured
      perl -0777 -i -pe 's#(<a[^>]*class="skip-to-content"[^>]*>.*?</a>)#\1\n<main id="main">#is' "$f" || true
    else
      # Fallback: open after <body>
      perl -0777 -i -pe 's#(<body\b[^>]*>)#\1\n<main id="main">#i' "$f" || true
    fi
    # Close before </body> (only in the branch where we created <main>)
    perl -0777 -i -pe 's#</body>#</main>\n</body>#i' "$f" || true
  fi
done

echo "✅ skip link + <main id=\"main\"> ensured on ${#FILES[@]} files."
