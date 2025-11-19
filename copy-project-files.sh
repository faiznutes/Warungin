#!/bin/bash

# Script untuk copy file project dari folder asli ke folder GitHub
# Usage: bash copy-project-files.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SOURCE_DIR="F:/Backup W11/Warungin"
DEST_DIR="."

echo -e "${BLUE}📦 Copy Project Files untuk GitHub${NC}"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Source directory tidak ditemukan: $SOURCE_DIR${NC}"
    echo -e "${YELLOW}Pastikan path benar atau edit script ini${NC}"
    exit 1
fi

echo -e "${YELLOW}Source: $SOURCE_DIR${NC}"
echo -e "${YELLOW}Destination: $DEST_DIR${NC}"
echo ""

# Confirm
read -p "Lanjutkan copy file? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Copy backend files
echo -e "${YELLOW}📁 Copying backend files...${NC}"
if [ -d "$SOURCE_DIR/src" ]; then
    cp -r "$SOURCE_DIR/src" "$DEST_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✅ Backend source copied${NC}"
fi

# Copy frontend (client)
echo -e "${YELLOW}📁 Copying frontend files...${NC}"
if [ -d "$SOURCE_DIR/client" ]; then
    # Exclude node_modules and dist
    rsync -av --exclude 'node_modules' --exclude 'dist' --exclude '.vite' \
        "$SOURCE_DIR/client/" "$DEST_DIR/client/" 2>/dev/null || \
    cp -r "$SOURCE_DIR/client" "$DEST_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✅ Frontend source copied${NC}"
fi

# Copy database files
echo -e "${YELLOW}📁 Copying database files...${NC}"
if [ -d "$SOURCE_DIR/prisma" ]; then
    cp -r "$SOURCE_DIR/prisma" "$DEST_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✅ Prisma schema & migrations copied${NC}"
fi

# Copy scripts
echo -e "${YELLOW}📁 Copying scripts...${NC}"
if [ -d "$SOURCE_DIR/scripts" ]; then
    mkdir -p "$DEST_DIR/scripts"
    # Copy only essential scripts
    for script in docker-startup.sh create-super-admin-docker.js; do
        if [ -f "$SOURCE_DIR/scripts/$script" ]; then
            cp "$SOURCE_DIR/scripts/$script" "$DEST_DIR/scripts/" 2>/dev/null || true
        fi
    done
    echo -e "${GREEN}✅ Essential scripts copied${NC}"
fi

# Copy nginx config
echo -e "${YELLOW}📁 Copying nginx configuration...${NC}"
if [ -d "$SOURCE_DIR/nginx" ]; then
    mkdir -p "$DEST_DIR/nginx/conf.d"
    if [ -f "$SOURCE_DIR/nginx/conf.d/default.conf" ]; then
        cp "$SOURCE_DIR/nginx/conf.d/default.conf" "$DEST_DIR/nginx/conf.d/" 2>/dev/null || true
    fi
    if [ -f "$SOURCE_DIR/nginx/nginx.conf" ]; then
        cp "$SOURCE_DIR/nginx/nginx.conf" "$DEST_DIR/nginx/" 2>/dev/null || true
    fi
    mkdir -p "$DEST_DIR/nginx/ssl" "$DEST_DIR/nginx/logs"
    echo -e "${GREEN}✅ Nginx config copied${NC}"
fi

# Copy package files
echo -e "${YELLOW}📁 Copying package files...${NC}"
if [ -f "$SOURCE_DIR/package.json" ]; then
    cp "$SOURCE_DIR/package.json" "$DEST_DIR/" 2>/dev/null || true
    cp "$SOURCE_DIR/package-lock.json" "$DEST_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✅ Package files copied${NC}"
fi

if [ -f "$SOURCE_DIR/tsconfig.json" ]; then
    cp "$SOURCE_DIR/tsconfig.json" "$DEST_DIR/" 2>/dev/null || true
fi

# Copy client package files
if [ -f "$SOURCE_DIR/client/package.json" ]; then
    cp "$SOURCE_DIR/client/package.json" "$DEST_DIR/client/" 2>/dev/null || true
    cp "$SOURCE_DIR/client/package-lock.json" "$DEST_DIR/client/" 2>/dev/null || true
    echo -e "${GREEN}✅ Client package files copied${NC}"
fi

# Copy client nginx.conf
if [ -f "$SOURCE_DIR/client/nginx.conf" ]; then
    cp "$SOURCE_DIR/client/nginx.conf" "$DEST_DIR/client/" 2>/dev/null || true
fi

# Create logs directory
mkdir -p "$DEST_DIR/logs"

echo ""
echo -e "${GREEN}✅ Copy selesai!${NC}"
echo ""
echo -e "${YELLOW}📝 Langkah selanjutnya:${NC}"
echo "  1. Review file yang sudah di-copy"
echo "  2. Pastikan .gitignore sudah benar"
echo "  3. Setup .env dari env.example"
echo "  4. Commit dan push ke GitHub:"
echo "     git add ."
echo "     git commit -m 'Initial commit: Warungin project'"
echo "     git push origin main"
echo ""

