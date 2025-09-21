#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
trap 'rc=$?; echo "❌ ERR repair_reports:$LINENO :: $BASH_COMMAND (rc=$rc)"; exit $rc' ERR
die(){ echo "❌ $*" >&2; exit 1; }
bak(){ local f="$1"; [[ -f "$f" ]] || die "No such file: $f"; local ts=$(date -u +%Y%m%dT%H%M%SZ); cp -p "$f" "${f}.bak.$ts"; echo "🛟 Backup -> ${f}.bak.$ts"; }

FILE="reports.html"; [[ -f "$FILE" ]] || die "Missing reports.html"

# 1) Ensure stylesheet & scripts in <head> (idempotent via markers)
if ! grep -q 'RBIS:STYLE' "$FILE"; then
  tmp="$(mktemp)"
  awk '
    BEGIN{ins=0}
    /<head[^>]*>/ && ins==0 {
      print;
      print "<!-- RBIS:STYLE:START -->";
      print "<link rel=\"stylesheet\" href=\"/assets/rbis.css\">";
      print "<!-- RBIS:STYLE:END -->";
      next
    }
    {print}
  ' "$FILE" > "$tmp"
  bak "$FILE"; mv "$tmp" "$FILE"
fi
if ! grep -q 'RBIS:SCRIPTS' "$FILE"; then
  tmp="$(mktemp)"
  awk '
    BEGIN{done=0}
    /<\/head>/ && done==0 {
      print "<!-- RBIS:SCRIPTS:START -->";
      print "<script src=\"/assets/rbis.js\" defer></script>";
      print "<script src=\"/assets/reports.js\" defer></script>";
      print "<!-- RBIS:SCRIPTS:END -->";
      print;
      done=1; next
    }
    {print}
  ' "$FILE" > "$tmp"
  bak "$FILE"; mv "$tmp" "$FILE"
fi

# 2) Ensure <main> with a #reports-root block containing filters + list
if ! grep -q 'id="reports-root"' "$FILE"; then
  tmp="$(mktemp)"
  awk '
    BEGIN{placed=0}
    /<main[^>]*>/ && placed==0 {
      print; 
      print "<section id=\"reports-root\" class=\"container section\">";
      print "  <header class=\"stack\">";
      print "    <h1>Reports</h1>";
      print "    <p class=\"muted\">Browse RBIS intelligence. Use filters or search to narrow results, then request the report you need.</p>";
      print "  </header>";
      print "  <div class=\"filterbar\">";
      print "    <input id=\"filter-q\" type=\"search\" placeholder=\"Search reports…\" aria-label=\"Search\">";
      print "    <select id=\"filter-type\" aria-label=\"Type\"><option value=\"\">Type</option><option>Fraud</option><option>Claims</option><option>Market</option><option>Trust</option></select>";
      print "    <select id=\"filter-industry\" aria-label=\"Industry\"><option value=\"\">Industry</option><option>Insurance</option><option>Legal/Corporate</option><option>Platform</option></select>";
      print "    <select id=\"filter-complexity\" aria-label=\"Complexity\"><option value=\"\">Complexity</option><option>Intermediate</option><option>Advanced</option></select>";
      print "    <select id=\"filter-cadence\" aria-label=\"Cadence\"><option value=\"\">Cadence</option><option>Ad-hoc</option><option>Monthly</option><option>Quarterly</option></select>";
      print "    <span class=\"muted\">Showing <strong id=\"reports-count\">0</strong></span>";
      print "  </div>";
      print "  <div id=\"reports\" class=\"grid cols-3\"></div>";
      print "  <div id=\"reports-empty\" class=\"empty hidden\">No reports match your filters.</div>";
      print "  <section class=\"stack\" style=\"margin-top:24px\">";
      print "    <h2>Report types</h2>";
      print "    <div class=\"grid cols-2\">";
      print "      <div class=\"card\"><h3>Fraud Intelligence Report</h3><p>Entity & network-level fraud patterns with behavioural markers, link analysis, and rule suggestions.</p></div>";
      print "      <div class=\"card\"><h3>Claims Pattern Analysis</h3><p>Time-series outliers, seasonal effects, cohort shifts, and human-review guardrails to reduce false flags.</p></div>";
      print "      <div class=\"card\"><h3>Competitor Behavioural Lens</h3><p>Competitive copy, pricing anchors, commitment devices, and frictions that influence conversion.</p></div>";
      print "      <div class=\"card\"><h3>Trust & Safety Risk Audit</h3><p>Abuse taxonomy coverage vs. policy, exploitability, and response maturity with red-team scenarios.</p></div>";
      print "    </div>";
      print "  </section>";
      print "</section>";
      placed=1; next
    }
    {print}
    END{
      if(placed==0){
        print "<main><section id=\"reports-root\" class=\"container section\"><h1>Reports</h1><div class=\"filterbar\"></div><div id=\"reports\" class=\"grid cols-3\"></div><div id=\"reports-empty\" class=\"empty hidden\">No reports match your filters.</div></section></main>"
      }
    }
  ' "$FILE" > "$tmp"
  bak "$FILE"; mv "$tmp" "$FILE"
fi

echo "✅ reports.html repaired and enhanced"
