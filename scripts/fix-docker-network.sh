#!/bin/bash
# Script untuk fix Docker network issues saat build
# Usage: bash scripts/fix-docker-network.sh

HOST="warungin@192.168.0.101"
PROJECT_PATH="/home/warungin/Warungin"

echo "Fixing Docker Network Issues"
echo "Password: 123"
echo ""

COMMANDS="
cd $PROJECT_PATH
echo '=== Checking Docker Network ==='
docker network ls
echo ''
echo '=== Checking DNS Resolution ==='
docker run --rm alpine nslookup registry.npmjs.org || echo 'DNS check failed'
echo ''
echo '=== Testing npm registry access from container ==='
docker run --rm node:18-alpine sh -c 'npm config get registry && npm ping' || echo 'npm registry unreachable'
echo ''
echo '=== Checking Docker Build Network Mode ==='
echo 'If network issues persist, try:'
echo '1. docker compose build --network=host backend'
echo '2. Or use build with DNS: docker compose build --build-arg BUILDKIT_INLINE_CACHE=1 backend'
echo ''
echo '=== Current Docker Build Cache ==='
docker builder prune --dry-run
"

ssh -o StrictHostKeyChecking=no "$HOST" "$COMMANDS"

