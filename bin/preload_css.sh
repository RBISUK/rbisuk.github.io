#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  grep -q 'rel="preload".*rbis.css' "$f" && continue
  awk '
    /<head[^>]*>/ && !added { print; print "<link rel=\"preload\" href=\"/assets/rbis.css\" as=\"style\">"; added=1; next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ preload rbis.css -> $f"
done
