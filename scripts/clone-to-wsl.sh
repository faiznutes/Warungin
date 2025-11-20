#!/bin/bash
# Clone repository ke WSL
# Usage: ./scripts/clone-to-wsl.sh [target-directory]

set -e

REPO_URL="https://github.com/faiznutes/Warungin.git"
TARGET_DIR="${1:-~/Warungin}"

echo "📦 Cloning Warungin repository..."
echo "   Target: $TARGET_DIR"
echo ""

# Expand ~ to home directory
TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

# Check if target directory exists
if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  Directory $TARGET_DIR sudah ada"
    read -p "Apakah Anda ingin menghapus dan clone ulang? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Menghapus directory lama..."
        rm -rf "$TARGET_DIR"
    else
        echo "ℹ️  Menggunakan directory yang sudah ada"
        cd "$TARGET_DIR"
        if [ -d ".git" ]; then
            echo "📥 Pulling latest changes..."
            git pull
        fi
        exit 0
    fi
fi

# Clone repository
echo "📥 Cloning repository..."
git clone "$REPO_URL" "$TARGET_DIR"

echo ""
echo "✅ Repository berhasil di-clone ke: $TARGET_DIR"
echo ""
echo "📂 Untuk masuk ke directory:"
echo "   cd $TARGET_DIR"
echo ""

