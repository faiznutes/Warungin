#!/bin/bash

# Script untuk menghapus file dari GitHub Repository
# Script ini akan menghapus file dan push perubahan ke GitHub

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗑️  Hapus File dari GitHub Repository${NC}"
echo ""

# Cek apakah sudah ada git repo
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Belum ada Git repository!${NC}"
    echo -e "${YELLOW}Jalankan: git init${NC}"
    exit 1
fi

# Cek apakah remote sudah ada
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE_URL" ]; then
    echo -e "${RED}❌ Remote GitHub belum di-setup!${NC}"
    echo -e "${YELLOW}Jalankan: bash setup-github.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}Remote GitHub: $REMOTE_URL${NC}"
echo ""

# Fetch untuk mendapatkan file dari GitHub
echo -e "${YELLOW}📥 Mengambil informasi dari GitHub...${NC}"
git fetch origin 2>/dev/null

# Tampilkan file yang ada di GitHub (branch main/master)
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
    BRANCH="main"
    git checkout -b main 2>/dev/null
fi

# Cek file di remote
echo ""
echo -e "${YELLOW}📋 File yang ada di GitHub (branch: $BRANCH):${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git ls-tree -r --name-only origin/$BRANCH 2>/dev/null || git ls-tree -r --name-only HEAD 2>/dev/null || echo "Belum ada file di GitHub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Tampilkan file lokal
echo -e "${YELLOW}📋 File lokal di repository:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
find . -type f -not -path './.git/*' -not -path './node_modules/*' | sed 's|^\./||' | sort
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Pilih opsi:"
echo "1) Hapus semua file dari GitHub (kosongkan repo)"
echo "2) Hapus file tertentu"
echo "3) Hapus semua file kecuali file penting (README, .gitignore, dll)"
echo ""
read -p "Pilihan (1-3): " choice

case $choice in
    1)
        echo ""
        echo -e "${RED}⚠️  PERINGATAN: Ini akan menghapus SEMUA file dari GitHub!${NC}"
        read -p "Yakin ingin melanjutkan? (ketik 'yes' untuk konfirmasi): " confirm
        
        if [ "$confirm" != "yes" ]; then
            echo -e "${YELLOW}Dibatalkan${NC}"
            exit 0
        fi
        
        # Hapus semua file kecuali .git
        echo ""
        echo -e "${YELLOW}🗑️  Menghapus semua file...${NC}"
        find . -type f -not -path './.git/*' -not -name 'delete-from-github.sh' -delete
        find . -type d -empty -not -path './.git/*' -delete
        
        # Commit perubahan
        git add -A
        git commit -m "Remove all files from repository" 2>/dev/null || echo "Tidak ada perubahan untuk di-commit"
        
        echo -e "${GREEN}✅ Semua file sudah dihapus${NC}"
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Masukkan nama file yang ingin dihapus:${NC}"
        echo "Contoh: file.txt atau folder/file.txt"
        echo "Untuk beberapa file, pisahkan dengan spasi"
        read -p "File: " files
        
        if [ -z "$files" ]; then
            echo -e "${RED}❌ Tidak ada file yang dipilih${NC}"
            exit 1
        fi
        
        echo ""
        echo -e "${YELLOW}🗑️  Menghapus file...${NC}"
        for file in $files; do
            if [ -f "$file" ] || [ -d "$file" ]; then
                rm -rf "$file"
                echo "  ✓ Hapus: $file"
            else
                echo "  ✗ File tidak ditemukan: $file"
            fi
        done
        
        # Commit perubahan
        git add -A
        git commit -m "Remove files: $files" 2>/dev/null || echo "Tidak ada perubahan untuk di-commit"
        
        echo -e "${GREEN}✅ File sudah dihapus${NC}"
        ;;
    3)
        echo ""
        echo -e "${YELLOW}🗑️  Menghapus file kecuali file penting...${NC}"
        
        # Hapus semua kecuali file penting
        find . -type f -not -path './.git/*' \
            -not -name 'README.md' \
            -not -name '.gitignore' \
            -not -name '*.sh' \
            -not -name '*.md' \
            -not -name 'delete-from-github.sh' \
            -delete
        
        find . -type d -empty -not -path './.git/*' -delete
        
        # Commit perubahan
        git add -A
        git commit -m "Clean repository - keep essential files only" 2>/dev/null || echo "Tidak ada perubahan untuk di-commit"
        
        echo -e "${GREEN}✅ File sudah dihapus (file penting tetap ada)${NC}"
        ;;
    *)
        echo -e "${RED}❌ Pilihan tidak valid${NC}"
        exit 1
        ;;
esac

# Push ke GitHub
echo ""
read -p "Push perubahan ke GitHub sekarang? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}🚀 Push ke GitHub...${NC}"
    git push origin "$BRANCH" --force 2>/dev/null || git push -u origin "$BRANCH" --force
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Berhasil! Perubahan sudah di-upload ke GitHub${NC}"
    else
        echo -e "${RED}❌ Gagal push ke GitHub${NC}"
        echo -e "${YELLOW}Pastikan authentication sudah di-setup dengan benar${NC}"
        echo -e "${YELLOW}Jalankan: bash setup-auth.sh${NC}"
    fi
else
    echo ""
    echo -e "${YELLOW}Perubahan sudah di-commit lokal${NC}"
    echo -e "${YELLOW}Untuk push nanti, jalankan: git push origin $BRANCH --force${NC}"
fi

