#!/bin/bash
# Script untuk check server dan mencari project path

HOST="warungin@192.168.0.101"

echo "Connecting to server..."
echo "Password: 123"
echo ""

# Command untuk mencari project
COMMANDS="
echo '=== Current Directory ==='
pwd
echo ''
echo '=== Home Directory ==='
ls -la ~
echo ''
echo '=== Searching for docker-compose.yml ==='
find ~ -name 'docker-compose.yml' -type f 2>/dev/null | head -5
echo ''
echo '=== Searching for Warungin directories ==='
find ~ -type d -iname '*warungin*' 2>/dev/null | head -5
echo ''
echo '=== Checking common locations ==='
[ -d ~/Warungin ] && echo 'Found: ~/Warungin' && ls -la ~/Warungin | head -3
[ -d ~/warungin ] && echo 'Found: ~/warungin' && ls -la ~/warungin | head -3
[ -d ~/projects/Warungin ] && echo 'Found: ~/projects/Warungin' && ls -la ~/projects/Warungin | head -3
echo ''
echo '=== Docker containers ==='
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || echo 'Docker not available'
"

ssh -o StrictHostKeyChecking=no "$HOST" "$COMMANDS"

