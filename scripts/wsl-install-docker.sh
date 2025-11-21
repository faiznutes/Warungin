#!/bin/bash
# Install Docker di WSL (step 1)
# Password: 123

set -e

PASSWORD="123"

echo "📦 Installing Docker di WSL..."
echo ""

sudo_cmd() {
    echo "$PASSWORD" | sudo -S bash -c "$1"
}

# Remove old versions
echo "   Removing old Docker versions..."
sudo_cmd "apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true"

# Install prerequisites
echo "   Installing prerequisites..."
sudo_cmd "apt-get update -qq"
sudo_cmd "apt-get install -y ca-certificates curl gnupg lsb-release"

# Add Docker GPG key
echo "   Adding Docker GPG key..."
sudo_cmd "mkdir -p /etc/apt/keyrings"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo_cmd "gpg --dearmor -o /etc/apt/keyrings/docker.gpg"

# Add Docker repository
echo "   Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo_cmd "tee /etc/apt/sources.list.d/docker.list > /dev/null"

# Install Docker
echo "   Installing Docker..."
sudo_cmd "apt-get update -qq"
sudo_cmd "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

# Add user to docker group
echo "   Adding user to docker group..."
sudo_cmd "usermod -aG docker $USER"

# Start Docker service
echo "   Starting Docker service..."
sudo_cmd "service docker start"

echo ""
echo "✅ Docker installed successfully!"
echo ""
echo "⚠️  IMPORTANT: Logout and login again, or run: newgrp docker"
echo ""
echo "📋 Verify installation:"
echo "   docker --version"
echo "   docker compose version"
echo ""

