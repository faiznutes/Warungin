#!/bin/bash
# Script untuk deploy/update code ke server
# Usage: bash scripts/deploy-to-server.sh

HOST="warungin@192.168.0.101"
PROJECT_PATH="/home/warungin/Warungin"
PASSWORD="123"

echo "=========================================="
echo "Deploying to Server: $HOST"
echo "Project Path: $PROJECT_PATH"
echo "Password: $PASSWORD"
echo "=========================================="
echo ""

# Command untuk deploy
COMMANDS="
cd $PROJECT_PATH
echo '=== Current Directory ==='
pwd
echo ''
echo '=== Git Status ==='
git status
echo ''
echo '=== Pulling Latest Changes ==='
git pull origin main
echo ''
echo '=== Checking Docker Containers ==='
docker ps --format 'table {{.Names}}\t{{.Status}}'
echo ''
echo '=== Rebuilding Backend (if needed) ==='
docker compose build --no-cache backend 2>/dev/null || docker-compose build --no-cache backend
echo ''
echo '=== Restarting Services ==='
docker compose restart 2>/dev/null || docker-compose restart
echo ''
echo '=== Final Status ==='
docker ps --format 'table {{.Names}}\t{{.Status}}'
echo ''
echo '=== Done! ==='
"

echo "Running deploy commands..."
echo "You will be prompted for password: $PASSWORD"
echo ""

ssh -o StrictHostKeyChecking=no "$HOST" "$COMMANDS"

echo ""
echo "=========================================="
echo "Deploy completed!"
echo "=========================================="

