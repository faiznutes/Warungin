#!/bin/bash

# Script untuk build dan deploy di WSL
# Usage: bash scripts/wsl-build-deploy.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔨 Building backend...${NC}"
sudo docker compose build backend

echo -e "${YELLOW}🛑 Stopping containers...${NC}"
sudo docker compose down

echo -e "${YELLOW}🚀 Starting containers...${NC}"
sudo docker compose up -d

echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 5

echo -e "${YELLOW}📊 Container status:${NC}"
sudo docker compose ps

echo -e "${GREEN}✅ Deploy completed!${NC}"

