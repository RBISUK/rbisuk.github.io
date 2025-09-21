#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
trap 'rc=$?; echo "❌ ERR repair_reports:$LINENO :: $BASH_COMMAND (rc=$rc)"; exit $rc' ERR
die(){ echo "❌ $*" >&2; exit 1; }
bak(){ local f="$1"; [[ -f "$f" ]] || die "No such file: $f"; local ts=$(date -u +%Y%m%dT%H%M%SZ); cp -p "$f" "${f}.bak.$ts"; echo "🛟 Backup -> ${f}.bak.$ts"; }
FILE="reports.html"; [[ -f "$FILE" ]] || die "Missing reports.html"

# Ensure CSS + scripts
if ! grep -q 'RBIS:STYLE' "$FILE"; then
  tmp="$(mktemp)"; awk '
    /<head[^>]*>/ && !ins { print; print "<!-- RBIS:STYLE:START -->"; print "<link rel=\"stylesheet\" href=\"/assets/rbis.css\">"; print "<!-- RBIS:STYLE:END -->"; ins=1; next } { print }' "$FILE" > "$tmp"
  bak "$FILE"; mv "$tmp" "$FILE"
fi
if ! grep -q 'RBIS:SCRIPTS' "$FILE"; then
  tmp="$(mktemp)"; awk '
    /<\/head>/ && !done { print "<!-- RBIS:SCRIPTS:START -->"; print "<script src=\"/assets/rbis.js\" defer></script>"; print "<script src=\"/assets/reports.js\" defer></script>"; print "<!-- RBIS:SCRIPTS:END -->"; print; done=1; next } { print }' "$FILE" > "$tmp"
  bak "$FILE"; mv "$tmp" "$FILE"
fi

# Inject dataset + filters + list
if ! grep -q 'id="reports-root"' "$FILE"; then
  tmp="$(mktemp)"; awk '
    BEGIN{placed=0}
    /<main[^>]*>/ && !placed {
      print;
      print "<section id=\"reports-root\" class=\"container section\">";
      print "  <header class=\"stack\"><h1>Reports</h1><p class=\"muted\">Browse RBIS intelligence. Filter, search, then request.</p></header>";
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
      print "  <script id=\"report-data\" type=\"application/json\">[{\"id\":\"fraud-intel\",\"title\":\"Fraud Intelligence Report\",\"type\":\"Fraud\",\"industry\":\"Insurance\",\"cadence\":\"Ad-hoc\",\"complexity\":\"Advanced\",\"updated\":\"2025-09-01\",\"tags\":[\"patterns\",\"link-analysis\",\"behavioural\"],\"summary\":\"Entity & network-level fraud patterns with behavioural markers.\",\"details\":\"Graph pivots, modus operandi, anomaly windows, rule suggestions.\"},{\"id\":\"claims-trends\",\"title\":\"Claims Pattern Analysis\",\"type\":\"Claims\",\"industry\":\"Insurance\",\"cadence\":\"Monthly\",\"complexity\":\"Intermediate\",\"updated\":\"2025-08-28\",\"tags\":[\"time-series\",\"seasonality\"],\"summary\":\"Outlier detection across cohorts and seasonality.\",\"details\":\"Trend families, mix shift, spike attribution, reviewer guardrails.\"},{\"id\":\"competitor-behav\",\"title\":\"Competitor Behavioural Lens\",\"type\":\"Market\",\"industry\":\"Legal/Corporate\",\"cadence\":\"Quarterly\",\"complexity\":\"Intermediate\",\"updated\":\"2025-08-10\",\"tags\":[\"positioning\",\"heuristics\"],\"summary\":\"Competitive narratives and choice architecture decoded.\",\"details\":\"Frictions, commitment devices, pricing anchors, copy heuristics.\"},{\"id\":\"trust-audit\",\"title\":\"Trust & Safety Risk Audit\",\"type\":\"Trust\",\"industry\":\"Platform\",\"cadence\":\"Ad-hoc\",\"complexity\":\"Advanced\",\"updated\":\"2025-09-12\",\"tags\":[\"abuse\",\"risk\",\"policy\"],\"summary\":\"Abuse taxonomy coverage vs. policy; exploitability review.\",\"details\":\"Known-bad patterns, emergent vectors, red-team scenarios, response maturity.\"}]</script>";
      print "</section>";
      placed=1; next
    }
    {print}
    END{
      if(!placed){
        print "<main><section id=\"reports-root\" class=\"container section\"><h1>Reports</h1><div class=\"filterbar\"></div><div id=\"reports\" class=\"grid cols-3\"></div><div id=\"reports-empty\" class=\"empty hidden\">No reports match your filters.</div></section></main>"
      }
    }
  ' "$FILE" > "$tmp"
  bak "$FILE"; mv "$tmp" "$FILE"
fi
echo "✅ reports.html repaired and enhanced"
