#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in "$@"; do
  # skip if already present
  grep -qi 'class="skip-to-content"' "$f" && continue
  # insert right after <body ...>
  perl -0777 -i -pe 's#(<body\b[^>]*>)#$1\n<a class="skip-to-content" href="#main">Skip to content</a>#i' "$f"
done
