#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
G='✅'; R='❌'; W='⚠️'; FAIL=0

# Pages to check (exclude generated stuff)
mapfile -t PAGES < <(git ls-files '*.html' | grep -Ev '^reports/|^drafts/' | sort)
echo "Checking ${#PAGES[@]} HTML pages (excluding reports/ & drafts/)"

# 1) No legacy nav
if (( ${#PAGES[@]} )) && ! grep -RInE '/assets/nav-fix\.css|/assets/nav-current\.js|id="rbis-nav"|id="nav-current"' -- "${PAGES[@]}" >/dev/null 2>&1; then
  echo "$G No legacy nav refs (css/js/ids)"
else
  echo "$R Legacy nav refs found:"; grep -RInE '/assets/nav-fix\.css|/assets/nav-current\.js|id="rbis-nav"|id="nav-current"' -- "${PAGES[@]}" || true
  FAIL=1
fi

# 2) Exactly one modern header
missing=(); dup=()
for f in "${PAGES[@]}"; do
  c=$(grep -o 'class="site-header"' "$f" | wc -l | tr -d ' ')
  ((c==0)) && missing+=("$f")
  ((c>1)) && dup+=("$f")
done
if (( ${#missing[@]}==0 && ${#dup[@]}==0 )); then
  echo "$G One true header present exactly once on every page"
else
  (( ${#missing[@]} )) && { echo "$R Missing header:"; printf '  - %s\n' "${missing[@]}"; FAIL=1; }
  (( ${#dup[@]} ))     && { echo "$R Duplicate headers:"; printf '  - %s\n' "${dup[@]}";     FAIL=1; }
fi

# 3) Skip link present
noskip=(); for f in "${PAGES[@]}"; do grep -qi 'class="skip-to-content"' "$f" || noskip+=("$f"); done
if (( ${#noskip[@]}==0 )); then echo "$G Skip link present on every page"; else
  echo "$R Missing skip link:"; printf '  - %s\n' "${noskip[@]}"; FAIL=1; fi

# 4) <main id="main"> present
nomain=(); for f in "${PAGES[@]}"; do grep -qi '<main\b[^>]*\bid="main"' "$f" || nomain+=("$f"); done
if (( ${#nomain[@]}==0 )); then echo "$G <main id=\"main\"> present on every page"; else
  echo "$R Missing <main id=\"main\">:"; printf '  - %s\n' "${nomain[@]}"; FAIL=1; fi

# 5) CSS exists + linked
[[ -f assets/site.v2.css ]] && echo "$G assets/site.v2.css exists" || { echo "$R assets/site.v2.css missing"; FAIL=1; }
if [[ -f assets/rbis.css ]] && grep -q 'site.v2.css' assets/rbis.css; then
  echo "$G assets/rbis.css imports site.v2.css"
else
  echo "$W assets/rbis.css does not import site.v2.css (or rbis.css missing)"
fi
nocss=(); for f in "${PAGES[@]}"; do grep -qiE '<link[^>]+href="/assets/(rbis\.css|site\.v2\.css)"' "$f" || nocss+=("$f"); done
if (( ${#nocss[@]}==0 )); then echo "$G Every page links rbis.css/site.v2.css"; else
  echo "$R Pages not linking rbis.css/site.v2.css:"; printf '  - %s\n' "${nocss[@]}"; FAIL=1; fi

# 6) nav-shadow helper (warn only)
noshadow=(); multi=()
for f in "${PAGES[@]}"; do
  c=$(grep -o '/assets/nav-shadow\.js' "$f" | wc -l | tr -d ' ')
  ((c==0)) && noshadow+=("$f"); ((c>1)) && multi+=("$f")
done
if (( ${#noshadow[@]}==0 && ${#multi[@]}==0 )); then
  echo "$G nav-shadow.js linked once per page"
else
  (( ${#noshadow[@]} )) && { echo "$W Missing nav-shadow.js (only affects shadow):"; printf '  - %s\n' "${noshadow[@]}"; }
  (( ${#multi[@]} ))   && { echo "$W Duplicate nav-shadow.js links:";               printf '  - %s\n' "${multi[@]}"; }
fi

# 7) No tracked backups
if ! git ls-files '*.bak' '*.html.bak' | grep . >/dev/null; then
  echo "$G No tracked backup files"
else
  echo "$R Tracked backups present:"; git ls-files '*.bak' '*.html.bak' | sed 's/^/  - /'; FAIL=1
fi

# Final
if (( FAIL==0 )); then echo -e "\n$G All checks passed"; else echo -e "\n$R Some checks failed"; exit 1; fi
