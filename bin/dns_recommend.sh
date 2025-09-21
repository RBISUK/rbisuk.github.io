#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
DOM="${SITE_DOMAIN:-rbisintelligence.com}"
cat > reports/dns_records.txt <<TXT
# Add these at your DNS provider (adjust hosts as needed)
; --- CAA (allow Let's Encrypt + Google Trust)
${DOM}. 3600 IN CAA 0 issue "letsencrypt.org"
${DOM}. 3600 IN CAA 0 issue "pki.goog"
${DOM}. 3600 IN CAA 0 iodef "mailto:security@${DOM}"

; --- SPF (allow MX + transactional provider example)
${DOM}. 3600 IN TXT "v=spf1 mx include:_spf.google.com ~all"

; --- DMARC (start as quarantine; move to reject after monitoring)
_dmarc.${DOM}. 3600 IN TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@${DOM}; ruf=mailto:dmarc@${DOM}; fo=1; adkim=s; aspf=s; pct=100"

; --- DKIM (create via your email provider; example selector)
google._domainkey.${DOM}. 3600 IN TXT "v=DKIM1; k=rsa; p=YOURPUBLICKEY"

; --- MTA-STS (optional hardening)
_mta-sts.${DOM}. 3600 IN TXT "v=STSv1; id=$(date -u +%Y%m%d)"
TXT
echo "📄 wrote reports/dns_records.txt"
