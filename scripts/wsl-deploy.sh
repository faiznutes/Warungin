#!/bin/bash
# Deploy script untuk WSL
# Menggunakan Windows SSH key atau direct connection

HOST="warungin@192.168.0.101"
PROJECT_PATH="/home/warungin/Warungin"
WSL_SSH_KEY="$HOME/.ssh/id_rsa_warungin"
WINDOWS_SSH_KEY="/mnt/c/Users/Iz/.ssh/id_rsa_warungin"

echo "=========================================="
echo "WSL Deploy to VPS"
echo "Server: $HOST"
echo "=========================================="
echo ""

# Determine which key to use
SSH_KEY=""
if [ -f "$WSL_SSH_KEY" ]; then
    SSH_KEY="-i $WSL_SSH_KEY"
    echo "Using WSL SSH key"
elif [ -f "$WINDOWS_SSH_KEY" ]; then
    SSH_KEY="-i $WINDOWS_SSH_KEY"
    echo "Using Windows SSH key"
else
    echo "No SSH key found, will use password"
fi

COMMANDS="
cd $PROJECT_PATH
echo '=== Current Directory ==='
pwd
echo ''
echo '=== Git Status ==='
git status --short
echo ''
echo '=== Pulling Latest Changes ==='
git pull origin main
echo ''
echo '=== Restarting Services ==='
docker compose restart 2>/dev/null || docker-compose restart
echo ''
echo '=== Container Status ==='
docker ps --format 'table {{.Names}}\t{{.Status}}'
"

echo "Running deploy..."
if [ -z "$SSH_KEY" ]; then
    echo "Password: 123"
fi
echo ""

ssh $SSH_KEY -o StrictHostKeyChecking=no "$HOST" "$COMMANDS"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deploy completed!"
else
    echo ""
    echo "❌ Deploy failed!"
    echo "Try using Git Bash instead: bash scripts/pull-and-deploy.sh"
    exit 1
fi

