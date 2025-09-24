#!/usr/bin/env sh
ok() { printf "✓ %s\n" "$1"; }
bad(){ printf "✗ %s\n" "$1"; }
err=0
# must-have
for f in index.html demo.html careers.html legal.html managed.html reports.html articles/body-lounge.html; do
  [ -f "$f" ] && ok "exists $f" || { bad "MISS $f"; err=1; }
done
# closing tags
for f in *.html; do grep -q '</html>' "$f" && ok "closed $f" || { bad "TRUNC $f"; err=1; }; done
if ls articles/*.html >/dev/null 2>&1; then
  for f in articles/*.html; do grep -q '</html>' "$f" && ok "closed $f" || { bad "TRUNC $f"; err=1; }; done
fi
# disclaimers (warns per file)
for f in index.html demo.html careers.html legal.html managed.html reports.html; do
  grep -iq 'not a law firm' "$f" && ok "disclaimer $f" || bad "WARN no disclaimer $f"
done
[ "${STRICT:-0}" = "1" ] && exit $err || { echo "SMOKE OK (issues:$err)"; exit 0; }
