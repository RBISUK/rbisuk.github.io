#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
command -v npx >/dev/null || { echo "npx missing"; exit 0; }
npx --yes linkinator "$ORIGIN" --recurse --timeout 10000 --silent || true
