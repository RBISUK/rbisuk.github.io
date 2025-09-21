#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  rg -q 'name="robots".*max-image-preview' "$f" && continue
  perl -0777 -pe 's#</head>#<meta name="robots" content="max-image-preview:large">\n</head>#i' -i "$f"
done
echo "✅ robots: max-image-preview:large"
