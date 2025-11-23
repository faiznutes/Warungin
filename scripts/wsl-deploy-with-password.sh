#!/bin/bash
# Deploy script untuk WSL dengan password
# Usage: bash scripts/wsl-deploy-with-password.sh

HOST="warungin@192.168.0.101"
PROJECT_PATH="/home/warungin/Warungin"
PASSWORD="123"

echo "=========================================="
echo "WSL Deploy to VPS (with password)"
echo "Server: $HOST"
echo "Password: $PASSWORD"
echo "=========================================="
echo ""

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
echo ''
echo '=== Done! ==='
"

echo "Running deploy..."
echo "You will be prompted for password: $PASSWORD"
echo ""

# Try using expect if available
if command -v expect &> /dev/null; then
    expect << EOF
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

