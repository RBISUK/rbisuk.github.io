#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
[[ -f careers.html ]] || exit 0
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
post=$(cat <<'JSON'
{
  "@context": "https://schema.org",
  "@type": "JobPosting",
  "title": "Open Applications (Talent Pool)",
  "description": "We’re always keen to hear from exceptional engineers, analysts and designers.",
  "hiringOrganization": {"@type":"Organization","name":"RBIS Intelligence","sameAs":"ORIGIN/"},
  "employmentType": "FULL_TIME",
  "applicantLocationRequirements": {"@type":"Country","name":"United Kingdom"},
  "jobLocationType": "TELECOMMUTE",
  "validThrough": "2030-01-01"
}
JSON
)
post="${post/ORIGIN/$ORIGIN}"
if rg -q 'id="schema-jobposting"' careers.html; then
  perl -0777 -pe 's#<script[^>]*id="schema-jobposting"[^>]*>.*?</script>#<script type="application/ld+json" id="schema-jobposting">'$(printf "%s" "$post" | sed -e 's/[&/\]/\\&/g')'</script>#s' -i careers.html
else
  perl -0777 -pe 's#</head>#<script type="application/ld+json" id="schema-jobposting">'$(printf "%s" "$post" | sed -e 's/[&/\]/\\&/g')'</script>\n</head>#s' -i careers.html
fi
echo "🧩 JobPosting schema -> careers.html"
