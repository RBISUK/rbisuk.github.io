#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
trap 'rc=$?; echo "❌ ERR reports_schema:$LINENO :: $BASH_COMMAND (rc=$rc)"; exit $rc' ERR
FILE="reports.html"; [[ -f "$FILE" ]] || { echo "no reports.html"; exit 0; }
DATA="$(awk '/<script id="report-data"/,/<\/script>/' "$FILE" | sed '1d;$d')"
[[ -z "${DATA:-}" ]] && { echo "no report-data"; exit 0; }

# Build ItemList
tmpjson="$(mktemp)"
{
  echo '{"@context":"https://schema.org","@type":"ItemList","name":"RBIS Reports","itemListElement":['
  i=1
  echo "$DATA" | sed 's/^\[//;s/\]$//' | awk -v RS='},{' 'BEGIN{ORS=""}{p=$0; if(NR>1)print "},{"; else print "{"; print p "}" }' \
    | sed 's/"}{/},{/g' \
    | while read -r rec; do
        title=$(echo "$rec" | sed -n 's/.*"title":"\([^"]*\)".*/\1/p')
        id=$(echo "$rec" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
        printf '{"@type":"ListItem","position":%d,"item":{"@type":"CreativeWork","name":"%s","url":"https://www.rbisintelligence.com/reports.html#%s"}},' "$i" "$title" "$id"
        i=$((i+1))
      done | sed 's/,$//'
  echo ']}'
} > "$tmpjson"

# Inject (replace if present)
tmp="$(mktemp)"
awk -v SCHEMA="$(cat "$tmpjson")" '
  BEGIN{del=0}
  /<!-- RBIS:SCHEMA:START -->/ {del=1; next}
  /<!-- RBIS:SCHEMA:END -->/   {del=0; next}
  { if(!del) print }
  /<\/head>/ && !done {
    print "<!-- RBIS:SCHEMA:START -->";
    print "<script type=\"application/ld+json\">"; print SCHEMA; print "</script>";
    print "<!-- RBIS:SCHEMA:END -->";
    print; done=1; next
  }' "$FILE" > "$tmp"
cp -p "$FILE" "$FILE.bak.$(date -u +%Y%m%dT%H%M%SZ)"; mv "$tmp" "$FILE"; rm -f "$tmpjson"
echo "✅ JSON-LD injected"
