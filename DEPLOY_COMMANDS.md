# 🚀 Command untuk Deploy via SSH ke WSL

## Quick Deploy (Menggunakan Script)

### Opsi 1: Menggunakan WSL (Recommended)

```bash
# Di WSL
cd ~/Warungin
git pull origin main
bash scripts/remote-deploy-simple.sh
```

### Opsi 2: Menggunakan sshpass (Jika terinstall)

```bash
# Install sshpass dulu
sudo apt-get install sshpass  # Linux
# atau
brew install hudochenkov/sshpass/sshpass  # Mac

# Jalankan deploy
bash scripts/remote-deploy.sh
```

## Manual Deploy (Step by Step)

### Setup SSH Key (Agar Tidak Perlu Password)

```bash
# Generate SSH key (jika belum ada)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/wsl_key -N ""

# Copy key ke WSL
ssh-copy-id -i ~/.ssh/wsl_key.pub root@172.27.30.45

# Atau manual:
cat ~/.ssh/wsl_key.pub | ssh root@172.27.30.45 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### Deploy Manual

```bash
# 1. Pull latest code
ssh -i ~/.ssh/wsl_key root@172.27.30.45 "cd ~/Warungin && git pull origin main"

# 2. Rebuild backend
ssh -i ~/.ssh/wsl_key root@172.27.30.45 "cd ~/Warungin && docker compose build backend"

# 3. Create super admin
ssh -i ~/.ssh/wsl_key root@172.27.30.45 "cd ~/Warungin && docker compose exec -T backend node scripts/create-super-admin-docker.js"

# 4. Restart services
ssh -i ~/.ssh/wsl_key root@172.27.30.45 "cd ~/Warungin && docker compose restart backend nginx"

# 5. Rebuild frontend
ssh -i ~/.ssh/wsl_key root@172.27.30.45 "cd ~/Warungin && docker compose build frontend && docker compose up -d frontend"

# 6. Check status
ssh -i ~/.ssh/wsl_key root@172.27.30.45 "cd ~/Warungin && docker compose ps"
```

## Menggunakan expect (Untuk Password Automation)

```bash
# Install expect
sudo apt-get install expect

# Gunakan script
bash scripts/remote-deploy-simple.sh
```

## Quick Fix All Issues

```bash
# Connect dan fix semua dalam satu command
ssh root@172.27.30.45 << 'EOF'
cd ~/Warungin

# Pull latest
git pull origin main

# Fix JWT_SECRET if needed
if ! grep -q "JWT_SECRET=" .env || grep -q "CHANGE_THIS" .env; then
  JWT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
  JWT_REFRESH=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
  sed -i "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" .env
  sed -i "s/JWT_REFRESH_SECRET=.*/JWT_REFRESH_SECRET=$JWT_REFRESH/" .env
fi

# Rebuild backend
docker compose build backend

# Create super admin
docker compose exec -T backend node scripts/create-super-admin-docker.js

# Restart services
docker compose restart backend nginx

# Rebuild frontend
docker compose build frontend
docker compose up -d frontend

# Check status
docker compose ps
echo ""
echo "✅ Deploy complete!"
EOF
```

## Troubleshooting SSH Stuck

### Problem: SSH command stuck waiting for password

**Solusi 1: Setup SSH Key (Recommended)**
```bash
ssh-keygen -t rsa
ssh-copy-id root@172.27.30.45
```

**Solusi 2: Gunakan sshpass**
```bash
# Install
sudo apt-get install sshpass

# Use
sshpass -p '123' ssh root@172.27.30.45 "command"
```

**Solusi 3: Gunakan expect**
```bash
expect << EOF
spawn ssh root@172.27.30.45 "command"
expect "password:"
send "123\r"
expect eof
EOF
```

**Solusi 4: Connect manual dulu**
```bash
# Connect manual sekali untuk accept host key
ssh root@172.27.30.45
# Masukkan password: 123
# Exit dengan: exit

# Setelah itu, command berikutnya tidak akan stuck
```

