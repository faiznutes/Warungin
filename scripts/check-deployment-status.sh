#!/bin/bash
# Check deployment status di WSL
# Mengecek Docker, containers, dan Cloudflare tunnel

REPO_DIR="$HOME/Warungin"
cd "$REPO_DIR" || exit 1

echo "🔍 Deployment Status Check"
echo "=========================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Check Docker
echo "🐳 [1/6] Docker Installation:"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version 2>&1)
    if echo "$DOCKER_VERSION" | grep -q "Docker Desktop"; then
        echo -e "   ${YELLOW}⚠️  Docker Desktop detected (WSL integration)${NC}"
        echo "   Version: $DOCKER_VERSION"
    else
        echo -e "   ${GREEN}✅ Docker installed${NC}"
        echo "   Version: $DOCKER_VERSION"
    fi
    
    # Check Docker daemon
    if docker info > /dev/null 2>&1; then
        echo -e "   ${GREEN}✅ Docker daemon running${NC}"
    else
        echo -e "   ${RED}❌ Docker daemon not running${NC}"
        echo "   Try: sudo service docker start"
    fi
else
    echo -e "   ${RED}❌ Docker not installed${NC}"
    echo "   Install with: bash scripts/wsl-install-docker.sh"
fi

echo ""

# 2. Check Docker Compose
echo "📦 [2/6] Docker Compose:"
if command -v docker-compose &> /dev/null || docker compose version > /dev/null 2>&1; then
    if docker compose version > /dev/null 2>&1; then
        COMPOSE_VERSION=$(docker compose version 2>&1)
    else
        COMPOSE_VERSION=$(docker-compose --version 2>&1)
    fi
    echo -e "   ${GREEN}✅ Docker Compose available${NC}"
    echo "   Version: $COMPOSE_VERSION"
else
    echo -e "   ${RED}❌ Docker Compose not available${NC}"
fi

echo ""

# 3. Check Docker Containers
echo "🐳 [3/6] Docker Containers:"
if command -v docker &> /dev/null && docker info > /dev/null 2>&1; then
    if [ -f "docker-compose.yml" ]; then
        echo "   Checking containers from docker-compose.yml..."
        
        # Check each service
        SERVICES=("postgres" "backend" "frontend" "nginx" "cloudflared")
        for SERVICE in "${SERVICES[@]}"; do
            CONTAINER_NAME="warungin-${SERVICE}"
            if docker ps -a --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
                STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)
                if [ "$STATUS" = "running" ]; then
                    echo -e "   ${GREEN}✅ ${SERVICE}: Running${NC}"
                else
                    echo -e "   ${RED}❌ ${SERVICE}: ${STATUS}${NC}"
                fi
            else
                echo -e "   ${YELLOW}⚠️  ${SERVICE}: Container not found${NC}"
            fi
        done
        
        echo ""
        echo "   All containers:"
        docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | head -10
    else
        echo -e "   ${YELLOW}⚠️  docker-compose.yml not found${NC}"
    fi
else
    echo -e "   ${RED}❌ Cannot check containers (Docker not available)${NC}"
fi

echo ""

# 4. Check Database
echo "🗄️  [4/6] Database (PostgreSQL):"
if command -v docker &> /dev/null && docker info > /dev/null 2>&1; then
    if docker ps --format "{{.Names}}" 2>/dev/null | grep -q "warungin-postgres"; then
        echo -e "   ${GREEN}✅ PostgreSQL container running${NC}"
        
        # Try to connect
        if docker exec warungin-postgres pg_isready -U postgres > /dev/null 2>&1; then
            echo -e "   ${GREEN}✅ Database is ready${NC}"
        else
            echo -e "   ${YELLOW}⚠️  Database not ready yet${NC}"
        fi
    else
        echo -e "   ${RED}❌ PostgreSQL container not running${NC}"
    fi
else
    echo -e "   ${RED}❌ Cannot check database (Docker not available)${NC}"
fi

echo ""

# 5. Check Backend & Frontend
echo "🚀 [5/6] Application Services:"
if command -v docker &> /dev/null && docker info > /dev/null 2>&1; then
    # Backend
    if docker ps --format "{{.Names}}" 2>/dev/null | grep -q "warungin-backend"; then
        BACKEND_STATUS=$(docker inspect -f '{{.State.Status}}' warungin-backend 2>/dev/null)
        if [ "$BACKEND_STATUS" = "running" ]; then
            echo -e "   ${GREEN}✅ Backend: Running${NC}"
            # Check health
            if docker exec warungin-backend wget --quiet --tries=1 --spider http://localhost:3000/health > /dev/null 2>&1; then
                echo -e "   ${GREEN}✅ Backend health check: OK${NC}"
            else
                echo -e "   ${YELLOW}⚠️  Backend health check: Not responding${NC}"
            fi
        else
            echo -e "   ${RED}❌ Backend: ${BACKEND_STATUS}${NC}"
        fi
    else
        echo -e "   ${RED}❌ Backend: Container not found${NC}"
    fi
    
    # Frontend
    if docker ps --format "{{.Names}}" 2>/dev/null | grep -q "warungin-frontend"; then
        FRONTEND_STATUS=$(docker inspect -f '{{.State.Status}}' warungin-frontend 2>/dev/null)
        if [ "$FRONTEND_STATUS" = "running" ]; then
            echo -e "   ${GREEN}✅ Frontend: Running${NC}"
        else
            echo -e "   ${RED}❌ Frontend: ${FRONTEND_STATUS}${NC}"
        fi
    else
        echo -e "   ${RED}❌ Frontend: Container not found${NC}"
    fi
    
    # Nginx
    if docker ps --format "{{.Names}}" 2>/dev/null | grep -q "warungin-nginx"; then
        NGINX_STATUS=$(docker inspect -f '{{.State.Status}}' warungin-nginx 2>/dev/null)
        if [ "$NGINX_STATUS" = "running" ]; then
            echo -e "   ${GREEN}✅ Nginx: Running${NC}"
        else
            echo -e "   ${RED}❌ Nginx: ${NGINX_STATUS}${NC}"
        fi
    else
        echo -e "   ${YELLOW}⚠️  Nginx: Container not found${NC}"
    fi
else
    echo -e "   ${RED}❌ Cannot check services (Docker not available)${NC}"
fi

echo ""

# 6. Check Cloudflare Tunnel
echo "☁️  [6/6] Cloudflare Tunnel:"
if command -v docker &> /dev/null && docker info > /dev/null 2>&1; then
    if docker ps --format "{{.Names}}" 2>/dev/null | grep -q "warungin-cloudflared"; then
        TUNNEL_STATUS=$(docker inspect -f '{{.State.Status}}' warungin-cloudflared 2>/dev/null)
        if [ "$TUNNEL_STATUS" = "running" ]; then
            echo -e "   ${GREEN}✅ Cloudflare Tunnel: Running${NC}"
            
            # Check tunnel info
            TUNNEL_INFO=$(docker exec warungin-cloudflared cloudflared tunnel info 2>&1)
            if echo "$TUNNEL_INFO" | grep -q "connector"; then
                echo "   Tunnel is connected"
            else
                echo -e "   ${YELLOW}⚠️  Tunnel may not be connected${NC}"
            fi
        else
            echo -e "   ${RED}❌ Cloudflare Tunnel: ${TUNNEL_STATUS}${NC}"
        fi
    else
        echo -e "   ${YELLOW}⚠️  Cloudflare Tunnel: Container not found${NC}"
        echo "   Start with: docker compose --profile cloudflare up -d cloudflared"
    fi
else
    echo -e "   ${RED}❌ Cannot check tunnel (Docker not available)${NC}"
fi

echo ""

# Summary
echo "📊 Summary:"
echo "=========="

TOTAL=0
RUNNING=0

if command -v docker &> /dev/null && docker info > /dev/null 2>&1; then
    SERVICES=("postgres" "backend" "frontend" "nginx")
    for SERVICE in "${SERVICES[@]}"; do
        CONTAINER_NAME="warungin-${SERVICE}"
        if docker ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
            TOTAL=$((TOTAL + 1))
            STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)
            if [ "$STATUS" = "running" ]; then
                RUNNING=$((RUNNING + 1))
            fi
        fi
    done
    
    echo "   Services: $RUNNING/$TOTAL running"
    
    if [ $RUNNING -eq $TOTAL ] && [ $TOTAL -gt 0 ]; then
        echo -e "   ${GREEN}✅ All services are running!${NC}"
    elif [ $RUNNING -gt 0 ]; then
        echo -e "   ${YELLOW}⚠️  Some services are not running${NC}"
    else
        echo -e "   ${RED}❌ No services are running${NC}"
        echo ""
        echo "   To start services:"
        echo "   cd ~/Warungin"
        echo "   docker compose up -d"
    fi
else
    echo -e "   ${RED}❌ Docker not available${NC}"
    echo ""
    echo "   To install Docker:"
    echo "   bash scripts/wsl-install-docker.sh"
fi

echo ""

