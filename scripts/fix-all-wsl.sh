#!/bin/bash
# Fix semua masalah di WSL - jalankan langsung di WSL
# Usage: bash scripts/fix-all-wsl.sh

set -e

REPO_DIR="$HOME/Warungin"
cd "$REPO_DIR" || exit 1

echo "🔧 Fix All Issues di WSL"
echo "========================"
echo ""

# 1. Pull latest code
echo "📥 [1/7] Pulling latest code..."
git pull origin main
echo ""

# 2. Check and fix .env
echo "⚙️  [2/7] Checking .env file..."
if [ ! -f .env ]; then
    echo "   Creating .env from env.example..."
    cp env.example .env
fi

# Check JWT_SECRET
if ! grep -q "JWT_SECRET=" .env || grep -q "CHANGE_THIS" .env; then
    echo "   Generating JWT secrets..."
    JWT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    JWT_REFRESH=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    sed -i "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" .env
    sed -i "s/JWT_REFRESH_SECRET=.*/JWT_REFRESH_SECRET=$JWT_REFRESH/" .env
    echo "   ✅ JWT secrets generated"
else
    echo "   ✅ JWT_SECRET already set"
fi
echo ""

# Check if we need sudo for docker
DOCKER_CMD="docker"
if ! docker ps &>/dev/null; then
    if sudo docker ps &>/dev/null; then
        DOCKER_CMD="sudo docker"
        echo "   Using sudo for docker commands"
    else
        echo "   ⚠️  Cannot access Docker. Please check Docker daemon."
        exit 1
    fi
fi

# 3. Rebuild backend
echo "🔨 [3/7] Rebuilding backend..."
$DOCKER_CMD compose build backend
echo "   ✅ Backend rebuilt"
echo ""

# 4. Create super admin
echo "👤 [4/7] Creating/updating super admin..."
$DOCKER_CMD compose exec -T backend node scripts/create-super-admin-docker.js || echo "   ⚠️  Super admin may already exist"
echo ""

# 5. Restart backend
echo "🔄 [5/7] Restarting backend..."
$DOCKER_CMD compose restart backend
sleep 5
echo "   ✅ Backend restarted"
echo ""

# 6. Rebuild frontend (fix 404 assets)
echo "🎨 [6/7] Rebuilding frontend..."
$DOCKER_CMD compose build frontend
$DOCKER_CMD compose up -d frontend
echo "   ✅ Frontend rebuilt"
echo ""

# 7. Restart nginx
echo "🌐 [7/7] Restarting nginx..."
$DOCKER_CMD compose restart nginx
echo "   ✅ Nginx restarted"
echo ""

# Check status
echo "📊 Deployment Status:"
$DOCKER_CMD compose ps
echo ""

echo "✅ All fixes applied!"
echo ""
echo "📋 Next steps:"
echo "   1. Wait 10-15 seconds"
echo "   2. Clear browser cache (Ctrl+Shift+Delete)"
echo "   3. Hard refresh (Ctrl+Shift+R)"
echo "   4. Login: admin@warungin.com / admin123"
echo ""

