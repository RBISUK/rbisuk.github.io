#!/usr/bin/env sh
set -u
fail=0

echo "— Files exist"
for f in reports.html reports-grid.html assets/header.js assets/header.css; do
  if [ -s "$f" ]; then echo "✓ $f"; else echo "✗ $f missing"; fail=1; fi
done

echo "— One banner per page"
for f in *.html; do
  c=$(grep -ioc 'not a law firm' "$f" 2>/dev/null || echo 0)
  if [ "$c" -eq 1 ]; then echo "✓ $f banner=1"; else echo "✗ $f banner=$c"; fail=1; fi
done
if ls articles/*.html >/dev/null 2>&1; then
  for f in articles/*.html; do
    c=$(grep -ioc 'not a law firm' "$f" 2>/dev/null || echo 0)
    if [ "$c" -eq 1 ]; then echo "✓ $f banner=1"; else echo "✗ $f banner=$c"; fail=1; fi
  done
fi

echo "— Table has 31 rows"
rows=$(grep -oE '<tr><td[^>]*>(A|B|C|D|E|F)[0-9]+' reports.html | wc -l | tr -d ' ')
[ "$rows" -eq 31 ] && echo "✓ reports.html rows=$rows" || { echo "✗ reports.html rows=$rows"; fail=1; }

echo "— Cards page has 31 items"
cards=$(grep -c 'data-copy="' reports-grid.html 2>/dev/null || echo 0)
[ "$cards" -eq 31 ] && echo "✓ reports-grid.html cards=$cards" || { echo "✗ reports-grid.html cards=$cards"; fail=1; }

echo "— Codes present in both pages"
CODES="A1 A2 A3 A4 A5 A6 A7 A8 A9 B1 B2 B3 B4 C1 C2 C3 C4 C5 C6 C7 D1 D2 D3 E1 E2 E3 E4 E5 F1 F2 F3"
for code in $CODES; do
  grep -q "$code" reports.html       || { echo "✗ missing $code in reports.html"; fail=1; }
  grep -q "$code" reports-grid.html  || { echo "✗ missing $code in reports-grid.html"; fail=1; }
done && echo "✓ all codes referenced"

echo "— Header nav contains Reports"
grep -q '"Reports"' assets/header.js && echo "✓ nav ok" || { echo "✗ nav missing Reports"; fail=1; }

[ "$fail" -eq 0 ] && { echo "ALL CHECKS PASSED"; exit 0; } || { echo "CHECKS FAILED"; exit 1; }
