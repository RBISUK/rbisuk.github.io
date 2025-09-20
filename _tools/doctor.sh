#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "❌ ERR at line $LINENO: $BASH_COMMAND" >&2' ERR
echo "— RBIS doctor — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "PWD: $(pwd)"
git rev-parse --is-inside-work-tree >/dev/null && echo "✔ git repo OK" || { echo "✖ not a git repo"; exit 1; }
echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Remote: $(git remote -v | sed -n '1p')"
echo "— files:"
for f in index.html reports.html products.html offerings.html assets/rbis.css assets/rbis.js; do
  [ -f "$f" ] && echo "  ✔ $f" || echo "  • (missing) $f"
done
echo "— tools:"
for c in git sed awk perl curl; do
  command -v "$c" >/dev/null && echo "  ✔ $c" || echo "  ✖ $c missing"
done
echo "— write test:"
touch .rbis_write_test && rm .rbis_write_test && echo "  ✔ can write here"
echo "— sanity reads:"
[ -f reports.html ] && head -n 3 reports.html || true
echo "OK ✅"
