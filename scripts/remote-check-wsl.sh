#!/bin/bash
# Remote check dan fix WSL deployment via SSH
# Usage: bash scripts/remote-check-wsl.sh

set -e

WSL_IP="172.27.30.45"
WSL_USER="root"
WSL_PASS="123"
REPO_DIR="~/Warungin"

echo "🔍 Remote Check WSL Deployment"
echo "================================"
echo ""

# Function untuk execute command via SSH
ssh_exec() {
    sshpass -p "$WSL_PASS" ssh -o StrictHostKeyChecking=no "$WSL_USER@$WSL_IP" "$1"
}

# Function untuk execute command dengan output
ssh_exec_output() {
    sshpass -p "$WSL_PASS" ssh -o StrictHostKeyChecking=no "$WSL_USER@$WSL_IP" "$1"
}

echo "📡 Connecting to WSL at $WSL_IP..."
echo ""

# 1. Check containers status
echo "🐳 [1/8] Checking Docker containers..."
CONTAINERS=$(ssh_exec_output "cd $REPO_DIR && docker compose ps --format json" 2>/dev/null || echo "[]")
echo "$CONTAINERS" | jq -r '.[] | "\(.Name): \(.State)"' 2>/dev/null || echo "   Checking containers..."
echo ""

# 2. Check backend logs for errors
echo "📋 [2/8] Checking backend logs (last 20 lines)..."
ssh_exec_output "cd $REPO_DIR && docker compose logs --tail 20 backend" 2>/dev/null | grep -i error || echo "   No recent errors"
echo ""

# 3. Check environment variables
echo "⚙️  [3/8] Checking environment variables..."
ssh_exec_output "cd $REPO_DIR && grep -E 'JWT_SECRET|DATABASE_URL|POSTGRES_PASSWORD' .env 2>/dev/null | sed 's/=.*/=***/' || echo '   .env file not found or variables missing'"
echo ""

# 4. Check database connection
echo "🗄️  [4/8] Testing database connection..."
DB_TEST=$(ssh_exec_output "cd $REPO_DIR && docker compose exec -T backend node -e \"const { PrismaClient } = require('@prisma/client'); const prisma = new PrismaClient(); prisma.\\\$connect().then(() => { console.log('OK'); process.exit(0); }).catch((e) => { console.error('ERROR:', e.message); process.exit(1); });\" 2>&1" 2>/dev/null)
if echo "$DB_TEST" | grep -q "OK"; then
    echo "   ✅ Database connected"
else
    echo "   ❌ Database connection failed"
    echo "   Error: $DB_TEST"
fi
echo ""

# 5. Check super admin exists
echo "👤 [5/8] Checking super admin..."
SUPER_ADMIN=$(ssh_exec_output "cd $REPO_DIR && docker compose exec -T postgres psql -U postgres -d warungin -t -c \"SELECT COUNT(*) FROM \\\"User\\\" WHERE role = 'SUPER_ADMIN';\" 2>/dev/null" 2>/dev/null | tr -d ' ')
if [ "$SUPER_ADMIN" -gt 0 ] 2>/dev/null; then
    echo "   ✅ Super admin exists"
else
    echo "   ❌ Super admin not found"
    echo "   Creating super admin..."
    ssh_exec "cd $REPO_DIR && docker compose exec -T backend node scripts/create-super-admin-docker.js" 2>/dev/null || echo "   ⚠️  Failed to create super admin"
fi
echo ""

# 6. Check frontend build
echo "🎨 [6/8] Checking frontend assets..."
FRONTEND_CHECK=$(ssh_exec_output "cd $REPO_DIR && docker compose exec -T frontend ls -la /usr/share/nginx/html/assets/ 2>/dev/null | head -5" 2>/dev/null)
if echo "$FRONTEND_CHECK" | grep -q "\.js"; then
    echo "   ✅ Frontend assets exist"
else
    echo "   ❌ Frontend assets missing"
    echo "   Rebuilding frontend..."
    ssh_exec "cd $REPO_DIR && docker compose build frontend && docker compose up -d frontend" 2>/dev/null || echo "   ⚠️  Failed to rebuild frontend"
fi
echo ""

# 7. Check backend health
echo "🏥 [7/8] Checking backend health..."
HEALTH=$(ssh_exec_output "cd $REPO_DIR && docker compose exec -T backend wget -q -O- http://localhost:3000/health 2>/dev/null || docker compose exec -T backend curl -s http://localhost:3000/health 2>/dev/null" 2>/dev/null)
if echo "$HEALTH" | grep -q "ok\|healthy\|status"; then
    echo "   ✅ Backend is healthy"
else
    echo "   ❌ Backend health check failed"
    echo "   Response: $HEALTH"
fi
echo ""

# 8. Check nginx configuration
echo "🌐 [8/8] Checking nginx configuration..."
NGINX_CHECK=$(ssh_exec_output "cd $REPO_DIR && docker compose exec -T nginx nginx -t 2>&1" 2>/dev/null)
if echo "$NGINX_CHECK" | grep -q "successful"; then
    echo "   ✅ Nginx configuration valid"
else
    echo "   ❌ Nginx configuration error"
    echo "   Error: $NGINX_CHECK"
fi
echo ""

echo "✅ Remote check complete!"
echo ""
echo "📝 Summary:"
echo "   - Check logs above for any errors"
echo "   - If super admin missing, it should be created"
echo "   - If frontend assets missing, frontend should be rebuilt"
echo ""

