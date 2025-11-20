#!/bin/bash
# Quick fix - hanya restart services tanpa rebuild penuh
# Usage: sudo bash scripts/quick-fix-wsl.sh

set -e

REPO_DIR="$HOME/Warungin"
cd "$REPO_DIR" || exit 1

echo "⚡ Quick Fix - Restart Services"
echo "================================"
echo ""

# Check Docker
if ! docker ps &>/dev/null; then
    echo "❌ Docker tidak bisa diakses. Pastikan Docker daemon running."
    exit 1
fi

# 1. Pull latest code
echo "📥 [1/4] Pulling latest code..."
git pull origin main
echo ""

# 2. Restart backend
echo "🔄 [2/4] Restarting backend..."
docker compose restart backend
sleep 3
echo "   ✅ Backend restarted"
echo ""

# 3. Restart frontend
echo "🎨 [3/4] Restarting frontend..."
docker compose restart frontend
sleep 2
echo "   ✅ Frontend restarted"
echo ""

# 4. Restart nginx
echo "🌐 [4/4] Restarting nginx..."
docker compose restart nginx
sleep 2
echo "   ✅ Nginx restarted"
echo ""

# Check status
echo "📊 Status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "✅ Quick fix complete!"
echo ""
echo "💡 Jika masih ada error, jalankan: sudo bash scripts/fix-all-wsl.sh"
echo ""

