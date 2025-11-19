#!/bin/bash

# Script untuk setup GitHub repository dan push project
# Usage: bash setup-github-repo.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔗 Setup GitHub Repository untuk Warungin${NC}"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git tidak terinstall!${NC}"
    exit 1
fi

# Initialize git if not already
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}📦 Initializing Git repository...${NC}"
    git init
    echo -e "${GREEN}✅ Git repository initialized${NC}"
fi

# Check if remote exists
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    echo -e "${YELLOW}Masukkan URL GitHub repository:${NC}"
    echo "Contoh: https://github.com/username/Warungin.git"
    read -p "URL: " GITHUB_URL
    
    if [ -z "$GITHUB_URL" ]; then
        echo -e "${RED}❌ URL tidak boleh kosong!${NC}"
        exit 1
    fi
    
    git remote add origin "$GITHUB_URL"
    echo -e "${GREEN}✅ Remote added${NC}"
else
    echo -e "${YELLOW}Remote sudah ada: $REMOTE_URL${NC}"
    read -p "Gunakan remote ini? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
        echo -e "${YELLOW}Masukkan URL GitHub repository baru:${NC}"
        read -p "URL: " GITHUB_URL
        git remote add origin "$GITHUB_URL"
    fi
fi

# Check current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "")

if [ -z "$BRANCH" ]; then
    git checkout -b main 2>/dev/null || git checkout -b master 2>/dev/null
    BRANCH=$(git branch --show-current)
fi

# Add all files
echo -e "${YELLOW}📝 Adding files...${NC}"
git add .

# Check if there are changes
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  Tidak ada perubahan untuk di-commit${NC}"
else
    # Commit
    echo -e "${YELLOW}💾 Creating commit...${NC}"
    git commit -m "Initial commit: Warungin POS System with Docker" || {
        echo -e "${YELLOW}⚠️  Commit failed atau tidak ada perubahan${NC}"
    }
fi

# Push
echo ""
read -p "Push ke GitHub sekarang? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🚀 Pushing to GitHub...${NC}"
    git push -u origin "$BRANCH" || {
        echo -e "${RED}❌ Push gagal!${NC}"
        echo -e "${YELLOW}Pastikan:${NC}"
        echo "  1. Repository sudah dibuat di GitHub"
        echo "  2. Authentication sudah di-setup (Personal Access Token atau SSH)"
        echo "  3. Jalankan: bash setup-auth.sh untuk setup authentication"
        exit 1
    }
    echo -e "${GREEN}✅ Push berhasil!${NC}"
else
    echo -e "${YELLOW}Untuk push nanti, jalankan:${NC}"
    echo "  git push -u origin $BRANCH"
fi

echo ""
echo -e "${GREEN}🎉 Setup selesai!${NC}"
echo ""
echo -e "${BLUE}📋 Repository Info:${NC}"
echo "  Remote: $(git remote get-url origin)"
echo "  Branch: $BRANCH"
echo ""

