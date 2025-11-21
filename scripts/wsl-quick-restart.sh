#!/bin/bash

# Script untuk quick restart tanpa rebuild (jika hanya perubahan code kecil)
# Usage: bash scripts/wsl-quick-restart.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔄 Quick restart (tanpa rebuild)...${NC}"
echo -e "${YELLOW}⚠️  Gunakan ini hanya jika tidak ada perubahan dependencies${NC}"

# Stop container
echo -e "${YELLOW}🛑 Stopping backend container...${NC}"
sudo docker compose stop backend

# Copy updated files to running container (jika container masih ada)
if sudo docker ps -a | grep -q warungin-backend; then
    echo -e "${YELLOW}📦 Copying updated files to container...${NC}"
    # Note: Untuk perubahan code, lebih baik rebuild atau restart dengan volume mount
    echo -e "${YELLOW}⚠️  Untuk perubahan code, gunakan: bash scripts/wsl-build-deploy.sh${NC}"
fi

# Restart container
echo -e "${YELLOW}🚀 Restarting backend container...${NC}"
sudo docker compose up -d backend

echo -e "${YELLOW}⏳ Waiting for service to start...${NC}"
sleep 3

echo -e "${YELLOW}📊 Container status:${NC}"
sudo docker compose ps backend

echo -e "${GREEN}✅ Quick restart completed!${NC}"
echo -e "${YELLOW}💡 Untuk melihat logs: sudo docker compose logs -f backend${NC}"

