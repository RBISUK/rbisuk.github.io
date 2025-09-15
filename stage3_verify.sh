set -e
cd /workspaces/rbisuk.github.io

echo "Running smoke…"
npm run -s smoke

echo "Installing deps (fast)…"
npm ci

echo "Building production (checks perf & type)…"
npm run -s build

echo
echo "Health endpoint (needs dev or start running):"
echo "  npm run dev   # then visit http://localhost:3000/api/health"
echo
echo "Open form:"
echo "  http://localhost:3000/form"
echo
echo "If you want a production server run:"
echo "  npm run start   # after build"
