#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  grep -qi 'rel="search".*opensearch' "$f" && continue
  awk '
    /<\/head>/ && !done { print "<link rel=\"search\" type=\"application/opensearchdescription+xml\" href=\"/opensearch.xml\">"; print; done=1; next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ opensearch link -> $f"
done
