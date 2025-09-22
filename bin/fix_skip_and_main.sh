#!/usr/bin/env bash
# Ensure there's a skip link + <main id="main"> on every HTML page.
# Idempotent and gentle: won't duplicate or mangle tags.

set -Eeuo pipefail; IFS=$'\n\t'

# Collect HTML files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

for f in "${FILES[@]}"; do
  # 1) Add skip link after <body> if missing
  if ! grep -qi 'class="skip-to-content"' "$f"; then
    perl -0777 -pe 's#<body([^>]*)>#<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>#i' -i "$f" || true
  fi

  # 2) If there is a <main> without any id, add id="main"
  perl -0777 -pe 's#<main(?![^>]*\bid=)([^>]*)>#<main id="main"$1>#i' -i "$f" || true

  # 3) If there is a <main id="somethingElse">, standardise to id="main"
  perl -0777 -pe 's#<main([^>]*?)\bid="(?!main")[^"]*"([^>]*)>#<main$1 id="main"$2>#i' -i "$f" || true

  # 4) If there is still NO <main> at all, wrap the page
  if ! grep -qi '<main\b' "$f"; then
    # open after the skip link if we have one, else right after <body>
    if grep -qi 'class="skip-to-content"' "$f"; then
      perl -0777 -pe 's#(<a[^>]*class="skip-to-content"[^>]*>.*?</a>)#\1\n<main id="main">#is' -i "$f" || true
    else
      perl -0777 -pe 's#(<body[^>]*>)#\1\n<main id="main">#i' -i "$f" || true
    fi
    # close just before </body> (only when we created a new <main>)
    perl -0777 -pe 's#</body>#</main>\n</body>#i' -i "$f" || true
  fi
done

echo "✅ skip link + <main id=\"main\"> ensured on ${#FILES[@]} files."
