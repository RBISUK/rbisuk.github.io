#!/usr/bin/env bash
set -Eeuo pipefail
RED=$'\033[31m'; GRN=$'\033[32m'; YEL=$'\033[33m'; BLU=$'\033[34m'; DIM=$'\033[2m'; NC=$'\033[0m'

DOMAIN="rbisintelligence.com"
WWW="www.${DOMAIN}"
EXPECT_CNAME="rbisuk.github.io"
IONOS_A="217.160.0.57"
IONOS_AAAA="2001:8d8:100f:f000::200"

iponly(){ grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true; }

ok(){ echo "${GRN}✔ $*${NC}"; }
warn(){ echo "${YEL}⚠ $*${NC}"; }
bad(){ echo "${RED}✖ $*${NC}"; }

echo "${BLU}— RBIS DNS Doctor — $(date -u +%Y-%m-%dT%H:%M:%SZ)${NC}"

# CNAME file (optional)
if [ -f CNAME ]; then
  CN=$(tr -d ' \t\r\n' < CNAME || true)
  [[ "$CN" == "www.${DOMAIN}" ]] && ok "Repo CNAME file = $CN" || warn "Repo CNAME is '$CN' (expected www.${DOMAIN})"
fi

# www CNAME
WCNAME=$(dig +short "$WWW" CNAME | sed 's/\.$//' )
[[ "$WCNAME" == "$EXPECT_CNAME" ]] && ok "DNS: $WWW CNAME → $WCNAME" || bad "DNS: $WWW CNAME is '$WCNAME' (expected $EXPECT_CNAME)"

# www A → GitHub Pages IPs
WIPS=($(dig +short "$WWW" A | iponly))
if ((${#WIPS[@]}==0)); then bad "DNS: $WWW has no A records (propagation?)"
else
  GH_OK=true
  for ip in "${WIPS[@]}"; do
    [[ "$ip" =~ ^185\.199\.(108|109|110|111)\.153$ ]] || GH_OK=false
  done
  $GH_OK && ok "DNS: $WWW A → ${WIPS[*]} (GitHub Pages)" || bad "DNS: $WWW A → ${WIPS[*]} (unexpected)"
fi

# Apex A/AAAA should be IONOS forwarders
A_APEX=$(dig +short "$DOMAIN" A | tr '\n' ' ')
AAAA_APEX=$(dig +short "$DOMAIN" AAAA | tr '\n' ' ')
[[ "$A_APEX" == *"$IONOS_A"* ]] && ok "DNS: $DOMAIN A includes IONOS $IONOS_A" || warn "DNS: $DOMAIN A ($A_APEX) — expected to include $IONOS_A"
[[ "$AAAA_APEX" == *"$IONOS_AAAA"* ]] && ok "DNS: $DOMAIN AAAA includes IONOS $IONOS_AAAA" || warn "DNS: $DOMAIN AAAA ($AAAA_APEX) — expected to include $IONOS_AAAA"

# HTTP→HTTPS checks
read -r CODE LOC <<<"$(curl -sSIL -o /dev/null -w "%{http_code} %{redirect_url}" "http://${DOMAIN}" || echo "000 -")"
[[ "$CODE" == "301" && "$LOC" == "https://www.${DOMAIN}/"* ]] \
  && ok "HTTP: ${DOMAIN} → 301 → ${LOC}" \
  || warn "HTTP: ${DOMAIN} returned $CODE (Location: $LOC)"

# HTTPS apex must also redirect (needs SSL forwarding at IONOS)
read -r SCODE SLOC <<<"$(curl -sSIL -o /dev/null -w "%{http_code} %{redirect_url}" "https://${DOMAIN}" || echo "000 -")"
[[ "$SCODE" == "301" && "$SLOC" == "https://www.${DOMAIN}/"* ]] \
  && ok "HTTPS: ${DOMAIN} → 301 → ${SLOC}" \
  || bad "HTTPS: ${DOMAIN} returned $SCODE (Location: $SLOC) — enable SSL forwarding at IONOS"

# www should 200
WCODE=$(curl -sSIL -o /dev/null -w "%{http_code}" "https://${WWW}")
[[ "$WCODE" == "200" ]] && ok "HTTPS: ${WWW} → 200 (GitHub Pages)" || bad "HTTPS: ${WWW} returned $WCODE"

echo "${DIM}If apex HTTPS still fails, attach a free SSL to the domain in IONOS, then re-run.${NC}"
