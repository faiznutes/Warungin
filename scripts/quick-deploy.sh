#!/bin/bash
# Quick deploy script - hanya pull dan restart
# Usage: bash scripts/quick-deploy.sh

HOST="warungin@192.168.0.101"
PROJECT_PATH="/home/warungin/Warungin"

echo "Quick Deploy to $HOST"
echo "Password: 123"
echo ""

ssh -o StrictHostKeyChecking=no "$HOST" "cd $PROJECT_PATH && git pull && (docker compose restart 2>/dev/null || docker-compose restart)"

echo "Done!"

