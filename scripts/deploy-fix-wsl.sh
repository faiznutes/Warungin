#!/bin/bash
# Deploy fix ke WSL 22.04
# Usage: sudo bash scripts/deploy-fix-wsl.sh

set -e

REPO_DIR="$HOME/Warungin"
cd "$REPO_DIR" || exit 1

echo "🚀 Deploy Fix ke WSL 22.04"
echo "==========================="
echo ""

# 1. Pull latest code
echo "📥 [1/5] Pulling latest code..."
git pull origin main
echo "   ✅ Code updated"
echo ""

# 2. Rebuild backend
echo "🔨 [2/5] Rebuilding backend..."
docker compose build backend
echo "   ✅ Backend rebuilt"
echo ""

# 3. Restart backend
echo "🔄 [3/5] Restarting backend..."
docker compose restart backend
sleep 5
echo "   ✅ Backend restarted"
echo ""

# 4. Check backend logs for errors
echo "📋 [4/5] Checking backend logs..."
docker compose logs backend --tail 30 | grep -i -E "(error|tenant|validation)" || echo "   No errors found"
echo ""

# 5. Check service status
echo "📊 [5/5] Service status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "✅ Deploy complete!"
echo ""
echo "📋 Test endpoint:"
echo "   curl -X POST https://pos.faiznute.site/api/tenants \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -H 'Authorization: Bearer YOUR_TOKEN' \\"
echo "     -d '{\"name\":\"Test Tenant\",\"subscriptionPlan\":\"BASIC\"}'"
echo ""

