#!/bin/bash
# Setup WSL dengan password untuk sudo commands
# Password: 123

set -e

PASSWORD="123"

echo "🔧 Setting up WSL dengan password..."
echo ""

# Function untuk menjalankan sudo command
sudo_cmd() {
    echo "$PASSWORD" | sudo -S bash -c "$1"
}

# Update package list
echo "📦 Updating package list..."
sudo_cmd "apt-get update -qq"

# Install essential tools
echo "📦 Installing essential tools..."
sudo_cmd "apt-get install -y git curl wget vim nano build-essential"

# Install Node.js jika belum ada
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -S bash -
    sudo_cmd "apt-get install -y nodejs"
else
    echo "✅ Node.js sudah terinstall: $(node --version)"
fi

# Install Docker (opsional)
read -p "Install Docker? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📦 Installing Docker..."
    sudo_cmd "apt-get install -y ca-certificates gnupg lsb-release"
    sudo_cmd "mkdir -p /etc/apt/keyrings"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo_cmd "gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo_cmd "tee /etc/apt/sources.list.d/docker.list > /dev/null"
    sudo_cmd "apt-get update -qq"
    sudo_cmd "apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin"
    sudo_cmd "usermod -aG docker $USER"
    echo "✅ Docker installed. Logout dan login lagi untuk menggunakan docker tanpa sudo."
fi

# Setup git config jika belum ada
if [ -z "$(git config --global user.name)" ]; then
    echo "📝 Setting git config..."
    git config --global user.name "Warungin Developer"
    git config --global user.email "developer@warungin.local"
fi

echo ""
echo "✅ Setup selesai!"
echo ""
echo "📋 Installed tools:"
echo "   - Git: $(git --version)"
if command -v node &> /dev/null; then
    echo "   - Node.js: $(node --version)"
    echo "   - npm: $(npm --version)"
fi
echo ""

