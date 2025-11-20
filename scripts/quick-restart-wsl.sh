#!/bin/bash
# Quick restart - hanya restart tanpa rebuild (lebih cepat)
# Usage: sudo bash scripts/quick-restart-wsl.sh

REPO_DIR="$HOME/Warungin"
cd "$REPO_DIR" || exit 1

echo "⚡ Quick Restart Services"
echo "========================"
echo ""

# Pull latest
echo "📥 Pulling latest code..."
git pull origin main 2>&1 | tail -5
echo ""

# Restart services
echo "🔄 Restarting services..."
docker compose restart backend frontend nginx 2>&1
echo ""

# Wait a bit
echo "⏳ Waiting 5 seconds..."
sleep 5
echo ""

# Check status
echo "📊 Status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}" 2>&1
echo ""

echo "✅ Quick restart complete!"
echo ""

