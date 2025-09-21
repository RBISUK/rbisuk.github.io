#!/usr/bin/env bash
# Read-only site audit: HTML/CSS inventory, stylesheets used, structural flags.
# No mutations. No hard exits. Always writes a summary.
set -u -o pipefail   # note: NOT using -e on purpose

IFS=$'\n\t'

warn(){ echo "⚠️  $*" >&2; }
info(){ echo "▶ $*"; }
ts(){ date -u +%Y%m%dT%H%M%SZ; }

OUT="audit/quick-$(ts)"
mkdir -p "$OUT"/{pages,css,live} || true

# 1) Repo snapshot (best-effort)
{
  echo "# Repo"
  git rev-parse --short HEAD 2>/dev/null | sed 's/^/- HEAD: /' || true
  git rev-parse --abbrev-ref HEAD 2>/dev/null | sed 's/^/- Branch: /' || true
  if git diff --quiet 2>/dev/null; then echo "- Dirty: no"; else echo "- Dirty: yes"; fi
} > "$OUT/repo.md"

# 2) CSS inventory
: > "$OUT/css/index.csv"
echo "path,size_bytes" >> "$OUT/css/index.csv"
for css in $(git ls-files '*.css' 2>/dev/null); do
  sz=$( (stat -c%s "$css" 2>/dev/null || stat -f%z "$css" 2>/dev/null) || echo 0 )
  echo "$css,$sz" >> "$OUT/css/index.csv"
done

# 3) HTML inventory
: > "$OUT/pages/index.csv"
echo "path,title,has_main,has_nav,nav_hidden,stylesheets_count,images,links,h1_count,meta_desc_len" >> "$OUT/pages/index.csv"

list_stylesheets(){
  # print one href per line (best-effort)
  grep -oi '<link[^>]*rel=["'\'']stylesheet["'\''][^>]*>' "$1" 2>/dev/null \
   | sed -n 's/.*href=["'\'']\([^"'\'']*\)["'\''].*/\1/pI'
}

extract_title(){ sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$1" 2>/dev/null | head -n1 | tr -s ' ' | sed 's/^ //;s/ $//' ; }
extract_desc(){ sed -n 's:.*<meta[^>]*name=["'\'']description["'\''][^>]*content=["'\'']\([^"'\'']*\)["'\''][^>]*>.*:\1:pI' "$1" 2>/dev/null | head -n1 ; }

for html in $(git ls-files '*.html' 2>/dev/null); do
  title="$(extract_title "$html")"
  has_main=$(grep -qi '<main' "$html" && echo yes || echo no)
  has_nav=$(grep -qi '<nav' "$html" && echo yes || echo no)
  nav_hidden=$(grep -Eqi '<nav[^>]*\b(hidden|aria-hidden)\b|class="[^"]*(sr-only|visually-hidden|(^| )hidden( |$))' "$html" && echo yes || echo no)
  styles_count=$(list_stylesheets "$html" | wc -l | tr -d ' ' || echo 0)
  imgs=$(grep -o '<img[[:space:]]' "$html" 2>/dev/null | wc -l | tr -d ' ' || echo 0)
  links=$(grep -o '<a[[:space:]]' "$html" 2>/dev/null | wc -l | tr -d ' ' || echo 0)
  h1s=$(grep -o '<h1[[:space:]]' "$html" 2>/dev/null | wc -l | tr -d ' ' || echo 0)
  dlen=$(extract_desc "$html" | wc -c | tr -d ' ' || echo 0)

  echo "$html,${title//,/ },$has_main,$has_nav,$nav_hidden,$styles_count,$imgs,$links,$h1s,$dlen" >> "$OUT/pages/index.csv"

  # per-page stylesheet list
  list_stylesheets "$html" > "$OUT/pages/${html//\//_}.styles.txt" || true
done

# 4) Which CSS files are actually referenced?
# Build a flat list of hrefs, then compare to tracked CSS files
cat "$OUT/pages/"*.styles.txt 2>/dev/null | sed '/^$/d' | sort -u > "$OUT/css/hrefs.txt" || true
git ls-files '*.css' 2>/dev/null | sort -u > "$OUT/css/tracked.txt" || true
# naive match: exact filenames (handles /assets/name.css and name.css)
awk -F/ '{print $NF}' "$OUT/css/hrefs.txt" 2>/dev/null | sort -u > "$OUT/css/hrefs_basenames.txt" || true
awk -F/ '{print $NF}' "$OUT/css/tracked.txt" 2>/dev/null | sort -u > "$OUT/css/tracked_basenames.txt" || true
comm -23 "$OUT/css/tracked_basenames.txt" "$OUT/css/hrefs_basenames.txt" 2>/dev/null > "$OUT/css/possibly_orphaned.txt" || true

# 5) Optional live probe (won't fail if offline)
ORIGIN="${ORIGIN:-https://www.rbisintelligence.com}"
probe(){
  url="$1"; dest="$2"
  curl -sS -D "$dest.headers" -o "$dest.body" "$url" >/dev/null 2>&1 || true
}
probe "$ORIGIN/" "$OUT/live/home"
probe "$ORIGIN/solutions.html" "$OUT/live/solutions"
probe "$ORIGIN/reports.html" "$OUT/live/reports"

# 6) Summary markdown
SUM="$OUT/summary.md"
{
  echo "# RBIS Quick Audit — $(ts)"
  echo
  echo "## Repo"
  cat "$OUT/repo.md" 2>/dev/null || true
  echo
  echo "## CSS (tracked) — count: $(wc -l < "$OUT/css/tracked.txt" 2>/dev/null || echo 0)"
  echo
  echo "Possibly orphaned (not referenced by any page):"
  if [[ -s "$OUT/css/possibly_orphaned.txt" ]]; then
    sed 's/^/- /' "$OUT/css/possibly_orphaned.txt"
  else
    echo "- <none detected>"
  fi
  echo
  echo "## Pages overview"
  echo
  echo "| path | title | main | nav | nav_hidden | styles | imgs | links | h1 | meta_desc_len |"
  echo "|---|---|:--:|:--:|:----------:|--:|--:|--:|--:|--:|"
  tail -n +2 "$OUT/pages/index.csv" 2>/dev/null | while IFS=, read -r p t m n nh sc im ln h1 md; do
    echo "| \`$p\` | ${t:-} | $m | $n | $nh | $sc | $im | $ln | $h1 | $md |"
  done
  echo
  echo "## Live probes (status lines)"
  for f in home solutions reports; do
    echo "### $ORIGIN (${f})"
    awk 'NR==1 || /^(HTTP|server:|content-type:|cache-control:|content-length:)/I' "$OUT/live/${f}.headers" 2>/dev/null || echo "<no headers>"
    echo
  done
} > "$SUM"

echo "✅ Audit complete."
echo "📝 Summary: $SUM"
