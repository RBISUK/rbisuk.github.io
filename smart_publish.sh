#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "❌ Failed at line $LINENO: $BASH_COMMAND" >&2' ERR

SURFACES_DIR="${SURFACES_DIR:-surfaces}"
DOMAIN="${DOMAIN:-www.rbisintelligence.com}"
REMOTE="${REMOTE:-https://github.com/RBISUK/rbisuk.github.io.git}"

SRC_REPO="$(git rev-parse --show-toplevel)"
SRC_SURFACES="$SRC_REPO/$SURFACES_DIR"
[[ -d "$SRC_SURFACES" ]] || { echo "✖ $SRC_SURFACES missing"; exit 1; }

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOGDIR="$SRC_REPO/_logs"; mkdir -p "$LOGDIR"
BKDIR="$SRC_REPO/_backups"; mkdir -p "$BKDIR"

# Deploy happens in a different clone = can't nuke your working .git
DEPLOY_DIR="$SRC_REPO/../_deploy_rbis"
if [ ! -d "$DEPLOY_DIR/.git" ]; then
  rm -rf "$DEPLOY_DIR" 2>/dev/null || true
  git clone --depth 1 "$REMOTE" "$DEPLOY_DIR"
fi

pushd "$DEPLOY_DIR" >/dev/null
git fetch --prune
git switch main
git pull --ff-only || true

# Safety: archive branch + tar backup of deploy tree
git branch "archive/${STAMP}" || true
git push -u origin "archive/${STAMP}" || true
tar -czf "$BKDIR/deploytree_${STAMP}.tar.gz" --exclude=.git .

# Clean deploy tree BUT keep .git
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy site from source /surfaces (no --delete needed since we cleaned)
rsync -a "$SRC_SURFACES"/ ./

# Stamps for sanity checking
touch .nojekyll
echo "$DOMAIN" > CNAME
date -u +%Y-%m-%dT%H:%M:%SZ > ping.txt
printf '{ "deployed":"%s", "source":"%s" }\n' "$(cat ping.txt)" "$SURFACES_DIR" > version.json

git add -A
git commit -m "Publish ${STAMP}" || echo "No changes to commit"
git push
popd >/dev/null

echo "✅ Published. Check:"
echo "  - https://www.rbisintelligence.com/version.json"
echo "  - https://www.rbisintelligence.com/ping.txt"
