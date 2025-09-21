#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p reports
for f in $(git ls-files '*.html'); do
  tidy -qe "$f" > "reports/tidy-$(basename "$f").txt" 2>&1 || true
  echo "🧾 tidy -> reports/tidy-$(basename "$f").txt"
done
echo "✅ tidy reports generated (check ./reports)"
