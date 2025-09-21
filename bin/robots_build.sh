#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
cat > robots.txt <<ROBOTS
User-agent: *
Allow: /
Sitemap: https://www.rbisintelligence.com/sitemap.xml
ROBOTS
echo "✅ robots.txt built"
