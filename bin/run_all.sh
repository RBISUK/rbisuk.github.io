#!/usr/bin/env bash
set -uo pipefail; IFS=$'\n\t'
fail=0
try(){ echo -e "\n▶ $*"; "$@" || { echo "❌ $*"; fail=1; }; }
try bash bin/build_sitemap.sh
try bash bin/sitemap_html.sh
try bash bin/reports_feed.sh
try bash bin/head_enhance.sh
try bash bin/ping_search.sh
try bash bin/critical_css.sh
try bash bin/a11y_pa11y.sh
try bash bin/og_check.sh
try bash bin/jsonld_check.sh
try bash bin/meta_audit.sh
echo -e "\n🧾 Done. Failures flagged above. Exit=$fail"
exit $fail
