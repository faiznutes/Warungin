#!/bin/bash

# Script Auto-Commit untuk Warungin
# Script ini akan commit dan push otomatis ke GitHub

# Warna untuk output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔄 Memulai Auto-Commit...${NC}"

# Cek apakah sudah ada git repo
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}📦 Menginisialisasi Git repository...${NC}"
    git init
fi

# Cek apakah ada perubahan
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${GREEN}✅ Tidak ada perubahan untuk di-commit${NC}"
    exit 0
fi

# Tambahkan semua perubahan
echo -e "${YELLOW}📝 Menambahkan perubahan...${NC}"
git add .

# Buat commit dengan timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
COMMIT_MSG="Auto-commit: $TIMESTAMP"

echo -e "${YELLOW}💾 Membuat commit...${NC}"
git commit -m "$COMMIT_MSG"

# Cek apakah remote sudah ada
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE_URL" ]; then
    echo -e "${RED}⚠️  Remote GitHub belum di-setup!${NC}"
    echo -e "${YELLOW}Jalankan: git remote add origin <URL_GITHUB_REPO>${NC}"
    echo -e "${YELLOW}Atau edit file setup-github.sh dan jalankan${NC}"
    exit 1
fi

# Push ke GitHub
echo -e "${YELLOW}🚀 Push ke GitHub...${NC}"
BRANCH=$(git branch --show-current)
git push origin "$BRANCH" || git push -u origin "$BRANCH"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Berhasil! Perubahan sudah di-upload ke GitHub${NC}"
else
    echo -e "${RED}❌ Gagal push ke GitHub. Periksa koneksi dan credentials${NC}"
    exit 1
fi

