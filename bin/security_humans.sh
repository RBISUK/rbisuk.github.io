#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p .well-known
[[ -f .well-known/security.txt ]] || cat > .well-known/security.txt <<TXT
Contact: mailto:security@rbisintelligence.com
Policy: https://www.rbisintelligence.com/trust/security/overview.html
Hiring: https://www.rbisintelligence.com/careers.html
Preferred-Languages: en
TXT
[[ -f .well-known/humans.txt ]] || cat > .well-known/humans.txt <<TXT
Team: RBIS Intelligence — https://www.rbisintelligence.com/
Technology: Static HTML, custom CSS, PWA offline
Standards: a11y, SEO, CSP, SRI
TXT
echo "✅ .well-known/security.txt + humans.txt"
