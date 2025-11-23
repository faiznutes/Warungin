#!/bin/bash
# Script untuk pull git terbaru dan deploy dengan error handling
# Usage: bash scripts/pull-and-deploy-safe.sh

HOST="warungin@192.168.0.101"
PROJECT_PATH="/home/warungin/Warungin"
PASSWORD="123"

echo "=========================================="
echo "Pull Latest Code & Deploy (Safe Mode)"
echo "Server: $HOST"
echo "Project: $PROJECT_PATH"
echo "Password: $PASSWORD"
echo "=========================================="
echo ""

# Command dengan error handling
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
PULL_EXIT=\$?
if [ \$PULL_EXIT -ne 0 ]; then
    echo 'Warning: Git pull had issues, but continuing...'
fi
echo ''
echo '=== Git Status (After) ==='
git status --short
echo ''
echo '=== Checking if rebuild is needed ==='
# Check if there are changes in src/ or package.json
if git diff --name-only HEAD~1 HEAD | grep -E '(src/|package.json|Dockerfile)' > /dev/null 2>&1; then
    echo 'Code changes detected, rebuilding backend...'
    echo 'Attempting rebuild (this may take a while)...'
    docker compose build --no-cache backend 2>&1 | tail -20
    BUILD_EXIT=\$?
    if [ \$BUILD_EXIT -ne 0 ]; then
        echo 'Warning: Build failed, but trying to continue with restart...'
        echo 'This might be due to network issues. Containers may use cached image.'
    fi
else
    echo 'No significant code changes detected, skipping rebuild.'
fi
echo ''
echo '=== Restarting Services ==='
docker compose restart 2>/dev/null || docker-compose restart
RESTART_EXIT=\$?
if [ \$RESTART_EXIT -ne 0 ]; then
    echo 'Error: Failed to restart containers'
    exit 1
fi
echo ''
echo '=== Waiting 5 seconds for services to start ==='
sleep 5
echo ''
echo '=== Final Container Status ==='
docker ps --format 'table {{.Names}}\t{{.Status}}'
echo ''
echo '=== Backend Health Check ==='
docker compose ps backend 2>/dev/null || docker-compose ps backend
echo ''
echo '=== Done! ==='
"

echo "Running pull and deploy (safe mode)..."
echo "You will be prompted for password: $PASSWORD"
echo ""

ssh -o StrictHostKeyChecking=no "$HOST" "$COMMANDS"

echo ""
echo "=========================================="
echo "Deploy completed!"
echo "=========================================="

