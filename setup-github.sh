#!/bin/bash

# Script Setup GitHub untuk Warungin
# Jalankan script ini untuk menghubungkan repo dengan GitHub

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔗 Setup GitHub Repository${NC}"
echo ""

# Cek apakah sudah ada git repo
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}📦 Menginisialisasi Git repository...${NC}"
    git init
fi

# Cek apakah remote sudah ada
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ ! -z "$REMOTE_URL" ]; then
    echo -e "${YELLOW}Remote sudah ada: $REMOTE_URL${NC}"
    read -p "Apakah Anda ingin mengganti remote? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    git remote remove origin
fi

# Input URL GitHub
echo -e "${YELLOW}Masukkan URL GitHub repository Anda:${NC}"
echo "Contoh: https://github.com/username/Warungin.git"
read -p "URL: " GITHUB_URL

if [ -z "$GITHUB_URL" ]; then
    echo -e "${RED}❌ URL tidak boleh kosong!${NC}"
    exit 1
fi

# Setup remote
echo -e "${YELLOW}🔗 Menghubungkan dengan GitHub...${NC}"
git remote add origin "$GITHUB_URL"

# Cek koneksi
echo -e "${YELLOW}🔍 Mengecek koneksi...${NC}"
git remote -v

# Setup branch main
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
    git checkout -b main
    BRANCH="main"
fi

# Commit pertama jika belum ada
if [ -z "$(git log --oneline -1 2>/dev/null)" ]; then
    echo -e "${YELLOW}📝 Membuat commit pertama...${NC}"
    git add .
    git commit -m "Initial commit"
fi

echo ""
echo -e "${GREEN}✅ Setup selesai!${NC}"
echo -e "${YELLOW}Untuk push pertama kali, jalankan:${NC}"
echo -e "  git push -u origin $BRANCH"
echo ""
echo -e "${YELLOW}Untuk auto-commit, jalankan:${NC}"
echo -e "  bash auto-commit.sh"

