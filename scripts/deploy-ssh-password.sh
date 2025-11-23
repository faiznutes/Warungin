#!/bin/bash

# Script untuk deploy ke server via SSH dengan password
# Usage: bash scripts/deploy-ssh-password.sh

set -e

SSH_HOST="192.168.0.101"
SSH_USER="warungin"
SSH_PASS="123"
REMOTE_DIR="~/Warungin"
GITHUB_REPO="https://github.com/faiznutes/Warungin.git"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Deploying to server ${SSH_USER}@${SSH_HOST}...${NC}"

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo -e "${RED}❌ sshpass tidak terinstall!${NC}"
    echo -e "${YELLOW}Install dengan:${NC}"
    echo "  Ubuntu/Debian: sudo apt-get install sshpass"
    echo "  Mac: brew install hudochenkov/sshpass/sshpass"
    exit 1
fi

# Function to run SSH command with password
ssh_cmd() {
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$SSH_HOST" "$1"
}

# Test SSH connection
echo -e "${YELLOW}🔌 Testing SSH connection...${NC}"
if ssh_cmd "echo 'Connection successful'"; then
    echo -e "${GREEN}✅ SSH connection OK${NC}"
else
    echo -e "${RED}❌ SSH connection failed!${NC}"
    exit 1
fi

# Check Docker
echo -e "${YELLOW}🐳 Checking Docker...${NC}"
if ssh_cmd "command -v docker &> /dev/null"; then
    echo -e "${GREEN}✅ Docker installed${NC}"
else
    echo -e "${RED}❌ Docker tidak terinstall di server!${NC}"
    exit 1
fi

# Setup repository
echo -e "${YELLOW}📦 Setting up repository...${NC}"
if ssh_cmd "[ -d '$REMOTE_DIR' ]"; then
    echo -e "${YELLOW}Repository sudah ada, updating...${NC}"
    ssh_cmd "cd $REMOTE_DIR && git pull origin main || git pull origin master"
else
    echo -e "${YELLOW}Cloning repository...${NC}"
    ssh_cmd "git clone $GITHUB_REPO $REMOTE_DIR" || {
        echo -e "${RED}❌ Git clone failed!${NC}"
        exit 1
    }
fi
echo -e "${GREEN}✅ Repository ready${NC}"

# Copy .env if needed
echo -e "${YELLOW}📝 Checking .env file...${NC}"
if ssh_cmd "[ ! -f '$REMOTE_DIR/.env' ]"; then
    echo -e "${YELLOW}Creating .env from env.example...${NC}"
    ssh_cmd "cd $REMOTE_DIR && cp env.example .env"
    echo -e "${RED}⚠️  PENTING: Edit .env file di server dengan konfigurasi yang benar!${NC}"
fi

# Deploy with Docker
echo -e "${YELLOW}🐳 Deploying with Docker...${NC}"
ssh_cmd "cd $REMOTE_DIR && docker compose down" 2>/dev/null || true
ssh_cmd "cd $REMOTE_DIR && docker compose pull" 2>/dev/null || true
ssh_cmd "cd $REMOTE_DIR && docker compose up -d --build"

# Wait for services
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 10

# Check status
echo -e "${YELLOW}📊 Service Status:${NC}"
ssh_cmd "cd $REMOTE_DIR && docker compose ps"

echo -e "${GREEN}✅ Deploy completed!${NC}"

