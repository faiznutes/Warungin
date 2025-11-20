#!/bin/bash
# Setup WSL untuk Git Clone
# Script untuk setup git dan clone repository di WSL

set -e

echo "🔧 Setting up WSL for Git..."
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "📦 Installing git..."
    sudo apt-get update
    sudo apt-get install -y git
else
    echo "✅ Git sudah terinstall: $(git --version)"
fi

echo ""
echo "📝 Setting up git config..."
echo ""

# Get user info for git config
read -p "Masukkan nama untuk git config (atau tekan Enter untuk skip): " GIT_NAME
read -p "Masukkan email untuk git config (atau tekan Enter untuk skip): " GIT_EMAIL

if [ -n "$GIT_NAME" ]; then
    git config --global user.name "$GIT_NAME"
    echo "✅ Git user.name di-set ke: $GIT_NAME"
fi

if [ -n "$GIT_EMAIL" ]; then
    git config --global user.email "$GIT_EMAIL"
    echo "✅ Git user.email di-set ke: $GIT_EMAIL"
fi

echo ""
echo "🔑 Setting up SSH keys for GitHub..."
echo ""

# Check if SSH key exists
if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
    echo "📝 SSH key belum ada. Membuat SSH key baru..."
    read -p "Masukkan email GitHub Anda: " GITHUB_EMAIL
    
    if [ -z "$GITHUB_EMAIL" ]; then
        echo "⚠️  Email tidak diberikan, menggunakan email dari git config..."
        GITHUB_EMAIL=$(git config --global user.email)
    fi
    
    if [ -z "$GITHUB_EMAIL" ]; then
        echo "❌ Email tidak ditemukan. Silakan setup git config terlebih dahulu."
        exit 1
    fi
    
    ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f ~/.ssh/id_ed25519 -N ""
    echo "✅ SSH key berhasil dibuat!"
    
    # Start ssh-agent
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    
    echo ""
    echo "📋 Public key Anda (copy ke GitHub Settings > SSH and GPG keys):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ~/.ssh/id_ed25519.pub
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🔗 Buka: https://github.com/settings/keys"
    echo "   Klik 'New SSH key', paste key di atas, dan klik 'Add SSH key'"
    echo ""
    read -p "Tekan Enter setelah menambahkan SSH key ke GitHub..."
else
    echo "✅ SSH key sudah ada"
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        echo "📋 Public key Anda:"
        cat ~/.ssh/id_ed25519.pub
    fi
fi

echo ""
echo "🧪 Testing SSH connection to GitHub..."
ssh -T git@github.com || echo "⚠️  SSH connection test (ini normal jika belum menambahkan key)"

echo ""
echo "📂 Setup selesai! Sekarang Anda bisa clone repository:"
echo ""
echo "   git clone git@github.com:faiznutes/Warungin.git"
echo "   atau"
echo "   git clone https://github.com/faiznutes/Warungin.git"
echo ""

