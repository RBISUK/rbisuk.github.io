set -euo pipefail

# Safety checks
test -d .git      || { echo "✖ Not in repo root (.git missing)"; exit 1; }
test -d surfaces  || { echo "✖ ./surfaces missing"; exit 1; }

# Start from remote tip
git switch main
git pull --ff-only

# Clean root but keep critical dirs/files
find . -mindepth 1 -maxdepth 1 \
  ! -name '.git' \
  ! -name '.github' \
  ! -name 'surfaces' \
  ! -name 'publish.sh' \
  -exec rm -rf {} +

# Publish built site
cp -a surfaces/. .
touch .nojekyll
echo "www.rbisintelligence.com" > CNAME

# Freshness stamps
date -u +%Y-%m-%dT%H:%M:%SZ > ping.txt
printf '{ "deployed":"%s" }\n' "$(cat ping.txt)" > version.json

git add -A
git commit -m "Publish site (Pages)"
git push
