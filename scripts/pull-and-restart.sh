#!/bin/bash
# Quick script: pull dan restart saja (tanpa rebuild)
# Usage: bash scripts/pull-and-restart.sh

# Try to use SSH config alias first, fallback to direct connection
if ssh -o ConnectTimeout=2 -o BatchMode=yes warungin-vps "echo" &>/dev/null; then
    HOST="warungin-vps"
    USE_PASSWORD=false
else
    HOST="warungin@192.168.0.101"
    USE_PASSWORD=true
fi

PROJECT_PATH="/home/warungin/Warungin"

echo "Quick Pull & Restart"
if [ "$USE_PASSWORD" = true ]; then
    echo "Password: 123"
else
    echo "Using SSH key (no password)"
fi
echo ""

ssh -o StrictHostKeyChecking=no "$HOST" "
cd $PROJECT_PATH && 
echo 'Pulling latest changes...' &&
git pull origin main &&
echo 'Restarting containers...' &&
(docker compose restart 2>/dev/null || docker-compose restart) &&
echo 'Done!'
"

