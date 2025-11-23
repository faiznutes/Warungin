#!/bin/bash
# Pull dan deploy lengkap dari WSL dengan password
# Usage: bash scripts/wsl-pull-and-deploy.sh

HOST="warungin@192.168.0.101"
PROJECT_PATH="/home/warungin/Warungin"
PASSWORD="123"

echo "=========================================="
echo "WSL Pull & Deploy (with password)"
echo "Server: $HOST"
echo "Password: $PASSWORD"
echo "=========================================="
echo ""

COMMANDS="
cd $PROJECT_PATH
echo '=== Current Directory ==='
pwd
echo ''
echo '=== Git Status (Before) ==='
git status --short
echo ''
echo '=== Pulling Latest Changes ==='
git pull origin main
echo ''
echo '=== Git Status (After) ==='
git status --short
echo ''
echo '=== Rebuilding Backend ==='
echo 'Note: If network error occurs, build will continue with cached layers'
docker compose build --network=host --no-cache backend 2>/dev/null || \
docker compose build --no-cache backend 2>/dev/null || \
docker-compose build --no-cache backend
echo ''
echo '=== Restarting Services ==='
docker compose restart 2>/dev/null || docker-compose restart
echo ''
echo '=== Waiting 5 seconds ==='
sleep 5
echo ''
echo '=== Container Status ==='
docker ps --format 'table {{.Names}}\t{{.Status}}'
echo ''
echo '=== Backend Logs (last 10 lines) ==='
docker compose logs --tail=10 backend 2>/dev/null || docker-compose logs --tail=10 backend
echo ''
echo '=== Done! ==='
"

echo "Running pull and deploy..."
echo "You will be prompted for password: $PASSWORD"
echo ""

# Try using expect if available
if command -v expect &> /dev/null; then
    expect << EOF
set timeout 300
spawn ssh -o StrictHostKeyChecking=no "$HOST" "$COMMANDS"
expect {
    "password:" {
        send "$PASSWORD\r"
        exp_continue
    }
    "(yes/no)?" {
        send "yes\r"
        exp_continue
    }
    eof {
        exit 0
    }
    timeout {
        puts "Connection timeout"
        exit 1
    }
}
EOF
else
    # Fallback: direct SSH (will prompt for password)
    echo "Note: expect not available, you need to enter password manually"
    ssh -o StrictHostKeyChecking=no "$HOST" "$COMMANDS"
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deploy completed!"
else
    echo ""
    echo "❌ Deploy failed!"
    exit 1
fi

