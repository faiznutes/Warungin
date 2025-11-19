#!/bin/bash

# Script Setup GitHub Authentication
# Pilih metode authentication yang ingin digunakan

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔐 Setup GitHub Authentication${NC}"
echo ""
echo "Pilih metode authentication:"
echo "1) Personal Access Token (Paling Mudah)"
echo "2) SSH Key (Lebih Aman)"
echo "3) GitHub CLI (gh)"
echo "4) Lihat panduan lengkap"
echo ""
read -p "Pilihan (1-4): " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}📋 Setup Personal Access Token${NC}"
        echo ""
        echo "Langkah-langkah:"
        echo "1. Buka: https://github.com/settings/tokens"
        echo "2. Klik 'Generate new token (classic)'"
        echo "3. Beri nama token"
        echo "4. Pilih scope 'repo'"
        echo "5. Generate dan copy token"
        echo ""
        read -p "Sudah membuat token? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${YELLOW}Setup credential helper...${NC}"
            git config --global credential.helper store
            
            echo ""
            echo -e "${GREEN}✅ Setup selesai!${NC}"
            echo ""
            echo -e "${YELLOW}Saat push pertama kali, masukkan:${NC}"
            echo "  Username: Gmail/username GitHub Anda"
            echo "  Password: Personal Access Token (bukan password Gmail!)"
            echo ""
            echo -e "${YELLOW}Test dengan: git push origin main${NC}"
        else
            echo -e "${YELLOW}Silakan buat token terlebih dahulu di:${NC}"
            echo "https://github.com/settings/tokens"
        fi
        ;;
    2)
        echo ""
        echo -e "${YELLOW}🔑 Setup SSH Key${NC}"
        echo ""
        read -p "Masukkan email Gmail Anda: " email
        
        if [ -z "$email" ]; then
            echo -e "${RED}❌ Email tidak boleh kosong!${NC}"
            exit 1
        fi
        
        echo ""
        echo -e "${YELLOW}Generating SSH key...${NC}"
        ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✅ SSH key berhasil dibuat!${NC}"
            echo ""
            echo -e "${YELLOW}📋 Public key Anda:${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            cat ~/.ssh/id_ed25519.pub
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo -e "${YELLOW}Langkah selanjutnya:${NC}"
            echo "1. Copy public key di atas"
            echo "2. Buka: https://github.com/settings/keys"
            echo "3. Klik 'New SSH key'"
            echo "4. Paste public key"
            echo "5. Klik 'Add SSH key'"
            echo ""
            read -p "Sudah menambahkan SSH key ke GitHub? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Test SSH connection
                echo ""
                echo -e "${YELLOW}🔍 Testing SSH connection...${NC}"
                ssh -T git@github.com
                
                # Update remote URL to SSH if exists
                REMOTE_URL=$(git remote get-url origin 2>/dev/null)
                if [ ! -z "$REMOTE_URL" ]; then
                    if [[ $REMOTE_URL == https://* ]]; then
                        echo ""
                        read -p "Ubah remote URL ke SSH? (y/n): " -n 1 -r
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            # Extract username and repo from HTTPS URL
                            if [[ $REMOTE_URL =~ github.com[:/]([^/]+)/([^/]+)\.git ]]; then
                                USERNAME=${BASH_REMATCH[1]}
                                REPO=${BASH_REMATCH[2]}
                                NEW_URL="git@github.com:$USERNAME/$REPO.git"
                                git remote set-url origin "$NEW_URL"
                                echo -e "${GREEN}✅ Remote URL diubah ke SSH${NC}"
                            fi
                        fi
                    fi
                fi
            fi
        else
            echo -e "${RED}❌ Gagal membuat SSH key${NC}"
        fi
        ;;
    3)
        echo ""
        echo -e "${YELLOW}📦 Setup GitHub CLI${NC}"
        echo ""
        echo "Pastikan GitHub CLI sudah terinstall:"
        echo "Download dari: https://cli.github.com/"
        echo ""
        read -p "GitHub CLI sudah terinstall? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${YELLOW}Login dengan GitHub CLI...${NC}"
            gh auth login
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Login berhasil!${NC}"
            else
                echo -e "${RED}❌ Login gagal${NC}"
            fi
        else
            echo -e "${YELLOW}Silakan install GitHub CLI terlebih dahulu${NC}"
        fi
        ;;
    4)
        echo ""
        echo -e "${YELLOW}📖 Membuka panduan...${NC}"
        if [ -f "setup-github-auth.md" ]; then
            cat setup-github-auth.md
        else
            echo "File panduan tidak ditemukan"
        fi
        ;;
    *)
        echo -e "${RED}❌ Pilihan tidak valid${NC}"
        exit 1
        ;;
esac

