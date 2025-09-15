#!/usr/bin/env bash
set -euo pipefail
URL="${1:-http://127.0.0.1:3000/api/submit/upload}"
if [ ! -f README.md ]; then echo "README.md not found; touching dummy file"; echo "RBIS" > README.md; fi
curl -fsS -F "file=@README.md" "$URL" | tee /dev/stderr | grep -q '"ok":true'
echo "✅ Upload smoke passed"
