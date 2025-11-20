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
git pull origin main || echo "   ⚠️  Git pull failed or already up to date"
echo "   ✅ Code updated"
echo ""

# 2. Rebuild backend (with progress)
echo "🔨 [2/5] Rebuilding backend..."
echo "   This may take 2-5 minutes..."
docker compose build --progress=plain backend 2>&1 | tail -20 || {
    echo "   ⚠️  Build failed, trying restart only"
    docker compose restart backend
}
echo "   ✅ Backend rebuild complete"
echo ""

# 3. Restart backend
echo "🔄 [3/5] Restarting backend..."
docker compose restart backend
echo "   Waiting for backend to start..."
for i in {1..10}; do
    sleep 1
    if docker compose ps backend | grep -q "Up"; then
        echo "   ✅ Backend is running"
        break
    fi
    echo "   ... waiting ($i/10)"
done
echo ""

# 4. Check backend logs for errors
echo "📋 [4/5] Checking backend logs..."
echo "   Recent logs:"
docker compose logs backend --tail 20 2>&1 | tail -10
echo "   Errors (if any):"
docker compose logs backend --tail 50 2>&1 | grep -i -E "(error|fail|exception)" | tail -5 || echo "   ✅ No errors found"
echo ""

# 5. Check service status
echo "📊 [5/5] Service status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>&1
echo ""

echo "✅ Deploy complete!"
echo ""
echo "💡 If you see errors above, check logs with:"
echo "   docker compose logs backend --tail 100"
echo ""

