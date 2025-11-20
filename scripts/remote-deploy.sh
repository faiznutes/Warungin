#!/bin/bash
# Remote deploy ke WSL via SSH dengan password
# Usage: bash scripts/remote-deploy.sh

set -e

WSL_IP="172.27.30.45"
WSL_USER="root"
WSL_PASS="123"
REPO_DIR="~/Warungin"

echo "🚀 Remote Deploy ke WSL"
echo "========================"
echo ""

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "📦 Installing sshpass..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -y sshpass
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install hudochenkov/sshpass/sshpass
    else
        echo "⚠️  Please install sshpass:"
        echo "   Linux: sudo apt-get install sshpass"
        echo "   Mac: brew install hudochenkov/sshpass/sshpass"
        echo "   Windows: Use WSL or install from https://github.com/keimpx/sshpass-win"
        exit 1
    fi
fi

# Function untuk execute command via SSH dengan password
ssh_exec() {
    sshpass -p "$WSL_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$WSL_USER@$WSL_IP" "$1"
}

echo "📡 Connecting to WSL at $WSL_IP..."
echo ""

# 1. Pull latest code
echo "📥 [1/6] Pulling latest code..."
ssh_exec "cd $REPO_DIR && git pull origin main" || echo "   ⚠️  Git pull failed or already up to date"
echo ""

# 2. Check JWT_SECRET
echo "⚙️  [2/6] Checking environment variables..."
JWT_SECRET=$(ssh_exec "cd $REPO_DIR && grep JWT_SECRET .env 2>/dev/null | cut -d'=' -f2" 2>/dev/null || echo "")
if [ -z "$JWT_SECRET" ] || [ "$JWT_SECRET" = "CHANGE_THIS_TO_RANDOM_32_CHARACTERS_MINIMUM" ]; then
    echo "   Generating JWT secrets..."
    NEW_JWT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    NEW_JWT_REFRESH=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    ssh_exec "cd $REPO_DIR && sed -i 's/JWT_SECRET=.*/JWT_SECRET=$NEW_JWT_SECRET/' .env && sed -i 's/JWT_REFRESH_SECRET=.*/JWT_REFRESH_SECRET=$NEW_JWT_REFRESH/' .env" 2>/dev/null
    echo "   ✅ JWT secrets generated"
else
    echo "   ✅ JWT_SECRET already set"
fi
echo ""

# 3. Rebuild backend
echo "🔨 [3/6] Rebuilding backend..."
ssh_exec "cd $REPO_DIR && docker compose build backend" 2>/dev/null || echo "   ⚠️  Build failed, trying restart only"
echo ""

# 4. Create super admin
echo "👤 [4/6] Creating/updating super admin..."
ssh_exec "cd $REPO_DIR && docker compose exec -T backend node scripts/create-super-admin-docker.js" 2>/dev/null || echo "   ⚠️  Super admin may already exist"
echo ""

# 5. Restart services
echo "🔄 [5/6] Restarting services..."
ssh_exec "cd $REPO_DIR && docker compose restart backend nginx" 2>/dev/null
sleep 5
echo "   ✅ Services restarted"
echo ""

# 6. Rebuild frontend (fix 404 assets)
echo "🎨 [6/6] Rebuilding frontend..."
ssh_exec "cd $REPO_DIR && docker compose build frontend && docker compose up -d frontend" 2>/dev/null || echo "   ⚠️  Frontend rebuild failed"
echo ""

# 7. Check status
echo "📊 Checking deployment status..."
ssh_exec "cd $REPO_DIR && docker compose ps --format 'table {{.Name}}\t{{.Status}}'" 2>/dev/null || echo "   ⚠️  Could not check status"
echo ""

echo "✅ Deploy complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Wait 10-15 seconds for services to start"
echo "   2. Clear browser cache (Ctrl+Shift+Delete)"
echo "   3. Hard refresh (Ctrl+Shift+R)"
echo "   4. Try login: admin@warungin.com / admin123"
echo ""

