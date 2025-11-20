#!/bin/bash
# Quick setup WSL untuk Git (non-interactive)
# Setup git config dan clone repository

set -e

echo "🔧 Quick Setup WSL untuk Git..."
echo ""

# Check git
if ! command -v git &> /dev/null; then
    echo "📦 Installing git..."
    sudo apt-get update -qq
    sudo apt-get install -y git
fi

echo "✅ Git: $(git --version)"
echo ""

# Setup git config (gunakan default jika belum di-set)
if [ -z "$(git config --global user.name)" ]; then
    echo "📝 Setting default git user.name..."
    git config --global user.name "Warungin Developer"
    echo "✅ Git user.name di-set (gunakan 'git config --global user.name \"Nama Anda\"' untuk mengubah)"
fi

if [ -z "$(git config --global user.email)" ]; then
    echo "📝 Setting default git user.email..."
    git config --global user.email "developer@warungin.local"
    echo "✅ Git user.email di-set (gunakan 'git config --global user.email \"email@example.com\"' untuk mengubah)"
fi

echo ""
echo "📋 Git config saat ini:"
git config --global --list | grep -E "user\.(name|email)" || true
echo ""

# Check SSH
if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
    echo "ℹ️  SSH key belum ada"
    echo "   Untuk setup SSH key, jalankan: ./scripts/setup-wsl-git.sh"
    echo "   Atau gunakan HTTPS untuk clone (tidak perlu SSH key)"
else
    echo "✅ SSH key sudah ada"
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        echo "   Public key: $(cat ~/.ssh/id_ed25519.pub | cut -d' ' -f1-2)..."
    fi
fi

echo ""
echo "✅ Setup selesai!"
echo ""
echo "📥 Untuk clone repository, jalankan:"
echo "   ./scripts/clone-to-wsl.sh"
echo "   atau"
echo "   git clone https://github.com/faiznutes/Warungin.git ~/Warungin"
echo ""

