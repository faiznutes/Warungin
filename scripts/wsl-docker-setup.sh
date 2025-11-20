#!/bin/bash
# Setup lengkap Docker di WSL hingga siap deploy
# Password: 123

set -e

PASSWORD="123"
REPO_DIR="$HOME/Warungin"

echo "🚀 Setup Docker di WSL untuk Deployment..."
echo ""

# Function untuk menjalankan sudo command
sudo_cmd() {
    echo "$PASSWORD" | sudo -S bash -c "$1"
}

# 1. Install Docker
echo "📦 [1/7] Installing Docker..."
if ! command -v docker &> /dev/null; then
    echo "   Removing old versions..."
    sudo_cmd "apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true"
    
    echo "   Installing prerequisites..."
    sudo_cmd "apt-get update -qq"
    sudo_cmd "apt-get install -y ca-certificates curl gnupg lsb-release"
    
    echo "   Adding Docker GPG key..."
    sudo_cmd "mkdir -p /etc/apt/keyrings"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo_cmd "gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
    
    echo "   Adding Docker repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo_cmd "tee /etc/apt/sources.list.d/docker.list > /dev/null"
    
    echo "   Installing Docker..."
    sudo_cmd "apt-get update -qq"
    sudo_cmd "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
    
    echo "   Adding user to docker group..."
    sudo_cmd "usermod -aG docker $USER"
    
    echo "✅ Docker installed successfully"
else
    echo "✅ Docker already installed: $(docker --version)"
fi

# 2. Install Node.js
echo ""
echo "📦 [2/7] Installing Node.js..."
if ! command -v node &> /dev/null; then
    echo "   Installing Node.js 18.x..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo_cmd "bash -"
    sudo_cmd "apt-get install -y nodejs"
    echo "✅ Node.js installed: $(node --version)"
    echo "✅ npm installed: $(npm --version)"
else
    echo "✅ Node.js already installed: $(node --version)"
fi

# 3. Clone/Update Repository
echo ""
echo "📦 [3/7] Setting up repository..."
if [ ! -d "$REPO_DIR" ]; then
    echo "   Cloning repository..."
    cd "$HOME"
    git clone https://github.com/faiznutes/Warungin.git
    echo "✅ Repository cloned"
else
    echo "   Repository already exists, pulling latest changes..."
    cd "$REPO_DIR"
    git pull origin main || echo "⚠️  Could not pull (may have local changes)"
    echo "✅ Repository updated"
fi

cd "$REPO_DIR"

# 4. Setup Environment Variables
echo ""
echo "📦 [4/7] Setting up environment variables..."
if [ ! -f .env ]; then
    echo "   Creating .env file from env.example..."
    cp env.example .env
    
    # Generate random passwords
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    JWT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    JWT_REFRESH_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    
    # Update .env with generated values
    sed -i "s/CHANGE_THIS_STRONG_PASSWORD/$DB_PASSWORD/g" .env
    sed -i "s/CHANGE_THIS_TO_RANDOM_32_CHARACTERS_MINIMUM/$JWT_SECRET/g" .env
    sed -i "0,/CHANGE_THIS_TO_RANDOM_32_CHARACTERS_MINIMUM/s//$JWT_REFRESH_SECRET/" .env
    
    echo "✅ .env file created with generated passwords"
    echo "   ⚠️  IMPORTANT: Edit .env file and update:"
    echo "      - FRONTEND_URL, BACKEND_URL, CORS_ORIGIN"
    echo "      - MIDTRANS credentials"
    echo "      - SMTP credentials"
else
    echo "✅ .env file already exists"
fi

# 5. Install Dependencies
echo ""
echo "📦 [5/7] Installing dependencies..."
echo "   Installing backend dependencies..."
npm install --legacy-peer-deps || npm install

echo "   Installing client dependencies..."
cd client
npm install --legacy-peer-deps || npm install
cd ..

echo "✅ Dependencies installed"

# 6. Start Docker services
echo ""
echo "📦 [6/7] Starting Docker services..."
echo "   Starting Docker daemon..."
sudo_cmd "service docker start" || true

# Wait a bit for Docker to be ready
sleep 2

# Check if Docker is running
if ! sudo_cmd "docker info > /dev/null 2>&1"; then
    echo "   ⚠️  Docker daemon not running, starting..."
    sudo_cmd "service docker start"
    sleep 3
fi

echo "   Building Docker images..."
cd "$REPO_DIR"
docker compose build --no-cache || echo "⚠️  Build failed, trying without --no-cache..."
docker compose build

echo "✅ Docker images built"

# 7. Start containers
echo ""
echo "📦 [7/7] Starting containers..."
docker compose up -d postgres
echo "   Waiting for database to be ready..."
sleep 10

docker compose up -d
echo "✅ Containers started"

# 8. Verify deployment
echo ""
echo "🔍 Verifying deployment..."
sleep 5

echo ""
echo "📊 Container Status:"
docker compose ps

echo ""
echo "📋 Services:"
echo "   - PostgreSQL: $(docker compose ps postgres | grep -q Up && echo '✅ Running' || echo '❌ Not running')"
echo "   - Backend: $(docker compose ps backend | grep -q Up && echo '✅ Running' || echo '❌ Not running')"
echo "   - Frontend: $(docker compose ps frontend | grep -q Up && echo '✅ Running' || echo '❌ Not running')"
echo "   - Nginx: $(docker compose ps nginx | grep -q Up && echo '✅ Running' || echo '❌ Not running')"

echo ""
echo "✅ Setup selesai!"
echo ""
echo "📝 Next steps:"
echo "   1. Edit .env file: nano $REPO_DIR/.env"
echo "   2. Update FRONTEND_URL, BACKEND_URL, CORS_ORIGIN"
echo "   3. Update MIDTRANS and SMTP credentials"
echo "   4. Restart containers: cd $REPO_DIR && docker compose restart"
echo ""
echo "🔧 Useful commands:"
echo "   - View logs: docker compose logs -f"
echo "   - Stop: docker compose down"
echo "   - Restart: docker compose restart"
echo "   - Status: docker compose ps"
echo ""

