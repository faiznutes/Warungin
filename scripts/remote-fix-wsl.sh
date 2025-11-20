#!/bin/bash
# Remote fix WSL deployment issues via SSH
# Usage: bash scripts/remote-fix-wsl.sh

set -e

WSL_IP="172.27.30.45"
WSL_USER="root"
WSL_PASS="123"
REPO_DIR="~/Warungin"

echo "🔧 Remote Fix WSL Deployment"
echo "============================="
echo ""

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "📦 Installing sshpass..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -y sshpass
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install hudochenkov/sshpass/sshpass
    else
        echo "⚠️  Please install sshpass manually"
        echo "   Linux: sudo apt-get install sshpass"
        echo "   Mac: brew install hudochenkov/sshpass/sshpass"
        exit 1
    fi
fi

# Function untuk execute command via SSH
ssh_exec() {
    sshpass -p "$WSL_PASS" ssh -o StrictHostKeyChecking=no "$WSL_USER@$WSL_IP" "$1"
}

echo "📡 Connecting to WSL at $WSL_IP..."
echo ""

# 1. Pull latest code
echo "📥 [1/7] Pulling latest code..."
ssh_exec "cd $REPO_DIR && git pull origin main" 2>/dev/null || echo "   ⚠️  Git pull failed or already up to date"
echo ""

# 2. Check and fix .env
echo "⚙️  [2/7] Checking .env file..."
ENV_EXISTS=$(ssh_exec "cd $REPO_DIR && test -f .env && echo 'yes' || echo 'no'")
if [ "$ENV_EXISTS" = "no" ]; then
    echo "   Creating .env from env.example..."
    ssh_exec "cd $REPO_DIR && cp env.example .env"
fi

# Check JWT_SECRET
JWT_SECRET=$(ssh_exec "cd $REPO_DIR && grep JWT_SECRET .env | cut -d'=' -f2" 2>/dev/null || echo "")
if [ -z "$JWT_SECRET" ] || [ "$JWT_SECRET" = "CHANGE_THIS_TO_RANDOM_32_CHARACTERS_MINIMUM" ]; then
    echo "   Generating JWT secrets..."
    NEW_JWT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    NEW_JWT_REFRESH=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    ssh_exec "cd $REPO_DIR && sed -i 's/JWT_SECRET=.*/JWT_SECRET=$NEW_JWT_SECRET/' .env && sed -i 's/JWT_REFRESH_SECRET=.*/JWT_REFRESH_SECRET=$NEW_JWT_REFRESH/' .env"
    echo "   ✅ JWT secrets generated"
fi
echo ""

# 3. Rebuild frontend (fix 404 assets)
echo "🎨 [3/7] Rebuilding frontend to fix 404 errors..."
ssh_exec "cd $REPO_DIR && docker compose build frontend" 2>/dev/null
ssh_exec "cd $REPO_DIR && docker compose up -d frontend" 2>/dev/null
echo "   ✅ Frontend rebuilt"
echo ""

# 4. Create super admin (fix 401 error)
echo "👤 [4/7] Creating/updating super admin..."
ssh_exec "cd $REPO_DIR && docker compose exec -T backend node scripts/create-super-admin-docker.js" 2>/dev/null || echo "   ⚠️  Super admin creation failed (may already exist)"
echo ""

# 5. Restart backend (apply new env vars)
echo "🔄 [5/7] Restarting backend..."
ssh_exec "cd $REPO_DIR && docker compose restart backend" 2>/dev/null
sleep 5
echo "   ✅ Backend restarted"
echo ""

# 6. Check backend health
echo "🏥 [6/7] Checking backend health..."
sleep 3
HEALTH=$(ssh_exec "cd $REPO_DIR && docker compose exec -T backend wget -q -O- http://localhost:3000/health 2>/dev/null || docker compose exec -T backend curl -s http://localhost:3000/health 2>/dev/null" 2>/dev/null)
if echo "$HEALTH" | grep -q "ok\|healthy\|status"; then
    echo "   ✅ Backend is healthy"
else
    echo "   ⚠️  Backend health check unclear"
    echo "   Response: $HEALTH"
fi
echo ""

# 7. Restart nginx
echo "🌐 [7/7] Restarting nginx..."
ssh_exec "cd $REPO_DIR && docker compose restart nginx" 2>/dev/null
echo "   ✅ Nginx restarted"
echo ""

echo "✅ Fix complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Wait 10-15 seconds for services to fully start"
echo "   2. Clear browser cache (Ctrl+Shift+Delete)"
echo "   3. Try login again:"
echo "      Email: admin@warungin.com"
echo "      Password: admin123"
echo "   4. Check browser console for any remaining errors"
echo ""

