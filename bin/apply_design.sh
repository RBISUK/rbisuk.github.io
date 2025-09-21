#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
trap 'rc=$?; echo "❌ ERR apply_design:$LINENO :: $BASH_COMMAND (rc=$rc)"; exit $rc' ERR
die(){ echo "❌ $*" >&2; exit 1; }
bak(){ local f="$1"; [[ -f "$f" ]] || die "No such file: $f"; local ts=$(date -u +%Y%m%dT%H%M%SZ); cp -p "$f" "${f}.bak.$ts"; echo "🛟 Backup -> ${f}.bak.$ts"; }
[[ -f assets/rbis.css ]] || die "assets/rbis.css missing"
[[ -f assets/rbis.js  ]] || die "assets/rbis.js missing"
git ls-files '*.html' | while read -r f; do
  [[ -f "$f" ]] || continue
  if ! grep -q 'RBIS:STYLE' "$f"; then
    tmp="$(mktemp)"; awk '
      BEGIN{ins=0}
      /<head[^>]*>/ && ins==0 { print; print "<!-- RBIS:STYLE:START -->"; print "<link rel=\"stylesheet\" href=\"/assets/rbis.css\">"; print "<!-- RBIS:STYLE:END -->"; ins=1; next }
      { print }' "$f" > "$tmp"; bak "$f"; mv "$tmp" "$f"
  fi
  if ! grep -q 'RBIS:SCRIPTS' "$f"; then
    tmp="$(mktemp)"; awk '
      BEGIN{done=0}
      /<\/head>/ && done==0 { print "<!-- RBIS:SCRIPTS:START -->"; print "<script src=\"/assets/rbis.js\" defer></script>"; print "<!-- RBIS:SCRIPTS:END -->"; print; done=1; next }
      { print }' "$f" > "$tmp"; bak "$f"; mv "$tmp" "$f"
  fi
done
echo "✅ design applied to all pages"
