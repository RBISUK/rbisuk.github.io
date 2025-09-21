#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
find reports/a11y -type f -name '*.html.html' -print -delete 2>/dev/null || true
echo "✅ cleaned reports/a11y/*.html.html duplicates"
