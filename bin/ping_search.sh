#!/usr/bin/env bash
set -euo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"; ORIGIN="${ORIGIN%/}"
echo "🔔 Soft-pinging search engines (non-fatal)…"
curl -fsS "https://www.google.com/ping?sitemap=${ORIGIN}/sitemap.xml" >/dev/null || echo "↪︎ Google ping skipped"
curl -fsS "https://www.google.com/ping?sitemap=${ORIGIN}/sitemap_index.xml" >/dev/null || echo "↪︎ Google index ping skipped"
curl -fsS "https://www.bing.com/ping?sitemap=${ORIGIN}/sitemap.xml" >/dev/null || echo "↪︎ Bing ping skipped"
