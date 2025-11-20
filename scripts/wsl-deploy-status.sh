#!/bin/bash
# Check deployment status

REPO_DIR="$HOME/Warungin"
cd "$REPO_DIR" || exit 1

echo "📊 Deployment Status Check"
echo "=========================="
echo ""

# Check Docker
echo "🐳 Docker:"
if command -v docker &> /dev/null; then
    echo "   ✅ Installed: $(docker --version)"
    if docker info > /dev/null 2>&1; then
        echo "   ✅ Daemon running"
    else
        echo "   ❌ Daemon not running (run: sudo service docker start)"
    fi
else
    echo "   ❌ Not installed"
fi

echo ""

# Check Node.js
echo "📦 Node.js:"
if command -v node &> /dev/null; then
    echo "   ✅ Installed: $(node --version)"
    echo "   ✅ npm: $(npm --version)"
else
    echo "   ❌ Not installed"
fi

echo ""

# Check Repository
echo "📂 Repository:"
if [ -d "$REPO_DIR" ]; then
    echo "   ✅ Location: $REPO_DIR"
    cd "$REPO_DIR"
    if [ -d ".git" ]; then
        echo "   ✅ Git repository"
        echo "   📋 Branch: $(git branch --show-current)"
        echo "   📋 Latest commit: $(git log -1 --oneline)"
    fi
else
    echo "   ❌ Not found"
fi

echo ""

# Check .env
echo "⚙️  Environment:"
if [ -f "$REPO_DIR/.env" ]; then
    echo "   ✅ .env file exists"
else
    echo "   ❌ .env file not found"
fi

echo ""

# Check Docker containers
echo "🐳 Docker Containers:"
if command -v docker &> /dev/null && docker info > /dev/null 2>&1; then
    cd "$REPO_DIR"
    if [ -f "docker-compose.yml" ]; then
        echo "   📋 Container status:"
        docker compose ps 2>/dev/null || docker-compose ps 2>/dev/null || echo "   ⚠️  Could not check containers"
    else
        echo "   ⚠️  docker-compose.yml not found"
    fi
else
    echo "   ⚠️  Docker not available"
fi

echo ""
echo "✅ Status check complete"

