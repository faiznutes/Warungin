#!/bin/bash
# Script untuk check server - JALANKAN DI GIT BASH
# Usage: bash scripts/check-server-manual.sh

HOST="warungin@192.168.0.101"
PASSWORD="123"

echo "=========================================="
echo "Checking Server: $HOST"
echo "Password: $PASSWORD"
echo "=========================================="
echo ""

# Command untuk mencari project
COMMANDS="
echo '=== Current Directory ==='
pwd
echo ''
echo '=== Home Directory Contents ==='
ls -la ~ | head -10
echo ''
echo '=== Searching for docker-compose.yml ==='
find ~ -name 'docker-compose.yml' -type f 2>/dev/null | head -5
echo ''
echo '=== Searching for Warungin directories ==='
find ~ -type d -iname '*warungin*' 2>/dev/null | head -5
echo ''
echo '=== Checking common project locations ==='
[ -d ~/Warungin ] && echo '✓ Found: ~/Warungin' && ls -la ~/Warungin | head -5 || echo '✗ ~/Warungin not found'
[ -d ~/warungin ] && echo '✓ Found: ~/warungin' && ls -la ~/warungin | head -5 || echo '✗ ~/warungin not found'
[ -d ~/projects/Warungin ] && echo '✓ Found: ~/projects/Warungin' && ls -la ~/projects/Warungin | head -5 || echo '✗ ~/projects/Warungin not found'
[ -d /var/www/warungin ] && echo '✓ Found: /var/www/warungin' && ls -la /var/www/warungin | head -5 || echo '✗ /var/www/warungin not found'
[ -d /opt/warungin ] && echo '✓ Found: /opt/warungin' && ls -la /opt/warungin | head -5 || echo '✗ /opt/warungin not found'
echo ''
echo '=== Docker Status ==='
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || echo 'Docker command not available'
echo ''
echo '=== Git Repositories ==='
find ~ -name '.git' -type d 2>/dev/null | head -5 | xargs dirname
"

echo "Running SSH command..."
echo "You will be prompted for password: $PASSWORD"
echo ""

ssh -o StrictHostKeyChecking=no "$HOST" "$COMMANDS"

echo ""
echo "=========================================="
echo "Done!"
echo "=========================================="

