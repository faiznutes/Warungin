#!/bin/bash
# Script untuk pull git terbaru dan deploy ke server
# Usage: bash scripts/pull-and-deploy.sh

# Try to use SSH config alias first, fallback to direct connection
if ssh -o ConnectTimeout=2 -o BatchMode=yes warungin-vps "echo" &>/dev/null; then
    HOST="warungin-vps"
    USE_PASSWORD=false
else
    HOST="warungin@192.168.0.101"
    USE_PASSWORD=true
    PASSWORD="123"
fi

PROJECT_PATH="/home/warungin/Warungin"

echo "=========================================="
echo "Pull Latest Code & Deploy"
echo "Server: $HOST"
echo "Project: $PROJECT_PATH"
echo "Password: $PASSWORD"
echo "=========================================="
echo ""

# Command lengkap: pull, build, restart
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
echo '=== Waiting 5 seconds for services to start ==='
sleep 5
echo ''
echo '=== Final Container Status ==='
docker ps --format 'table {{.Names}}\t{{.Status}}'
echo ''
echo '=== Backend Logs (last 20 lines) ==='
docker compose logs --tail=20 backend 2>/dev/null || docker-compose logs --tail=20 backend
echo ''
echo '=== Done! ==='
"

echo "Running pull and deploy..."
if [ "$USE_PASSWORD" = true ]; then
    echo "You will be prompted for password: $PASSWORD"
else
    echo "Using SSH key authentication (no password needed)"
fi
echo ""

ssh -o StrictHostKeyChecking=no "$HOST" "$COMMANDS"

echo ""
echo "=========================================="
echo "Deploy completed!"
echo "=========================================="

