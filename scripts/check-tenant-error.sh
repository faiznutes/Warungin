#!/bin/bash
# Check error pada tenant endpoint
# Usage: sudo bash scripts/check-tenant-error.sh

REPO_DIR="$HOME/Warungin"
cd "$REPO_DIR" || exit 1

echo "🔍 Checking Tenant Endpoint Errors"
echo "==================================="
echo ""

echo "📋 Backend logs (last 100 lines):"
docker compose logs backend --tail 100 | grep -i -E "(tenant|error|400|validation)" || echo "No tenant-related errors found"
echo ""

echo "📋 Recent errors:"
docker compose logs backend --tail 200 | grep -i error | tail -20
echo ""

echo "📋 Testing backend health:"
docker compose exec -T backend curl -s http://localhost:3000/health || echo "Backend not responding"
echo ""

echo "📋 Checking backend container:"
docker compose ps backend
echo ""

echo "✅ Check complete!"

