#!/bin/bash
# Simple remote deploy - menggunakan expect untuk handle password
# Usage: bash scripts/remote-deploy-simple.sh

WSL_IP="172.27.30.45"
WSL_USER="root"
WSL_PASS="123"
REPO_DIR="~/Warungin"

# Install expect jika belum ada
if ! command -v expect &> /dev/null; then
    echo "Installing expect..."
    sudo apt-get install -y expect 2>/dev/null || brew install expect 2>/dev/null || echo "Please install expect manually"
fi

# Function untuk execute command via SSH dengan expect
ssh_exec() {
    expect << EOF
set timeout 30
spawn ssh -o StrictHostKeyChecking=no $WSL_USER@$WSL_IP "$1"
expect {
    "password:" {
        send "$WSL_PASS\r"
        exp_continue
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    eof
}
EOF
}

echo "🚀 Remote Deploy ke WSL"
echo "========================"
echo ""

# 1. Pull latest
echo "📥 Pulling latest code..."
ssh_exec "cd $REPO_DIR && git pull origin main"
echo ""

# 2. Rebuild backend
echo "🔨 Rebuilding backend..."
ssh_exec "cd $REPO_DIR && docker compose build backend"
echo ""

# 3. Create super admin
echo "👤 Creating super admin..."
ssh_exec "cd $REPO_DIR && docker compose exec -T backend node scripts/create-super-admin-docker.js"
echo ""

# 4. Restart services
echo "🔄 Restarting services..."
ssh_exec "cd $REPO_DIR && docker compose restart backend nginx"
echo ""

# 5. Rebuild frontend
echo "🎨 Rebuilding frontend..."
ssh_exec "cd $REPO_DIR && docker compose build frontend && docker compose up -d frontend"
echo ""

# 6. Check status
echo "📊 Status:"
ssh_exec "cd $REPO_DIR && docker compose ps"
echo ""

echo "✅ Deploy complete!"

