#!/bin/bash
# Setup SSH untuk remote access ke WSL
# Password: 123

set -e

PASSWORD="123"

echo "🔧 Setting up SSH for WSL remote access..."
echo ""

# Function untuk menjalankan sudo command
sudo_cmd() {
    echo "$PASSWORD" | sudo -S bash -c "$1"
}

# 1. Install OpenSSH Server
echo "📦 [1/4] Installing OpenSSH Server..."
if ! command -v sshd &> /dev/null; then
    sudo_cmd "apt-get update -qq"
    sudo_cmd "apt-get install -y openssh-server"
    echo "✅ OpenSSH Server installed"
else
    echo "✅ OpenSSH Server already installed"
fi

# 2. Configure SSH
echo ""
echo "📦 [2/4] Configuring SSH..."
sudo_cmd "mkdir -p /etc/ssh"
sudo_cmd "mkdir -p /run/sshd"

# Backup original config
if [ ! -f /etc/ssh/sshd_config.backup ]; then
    sudo_cmd "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup"
fi

# Update SSH config
sudo_cmd "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config"
sudo_cmd "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"
sudo_cmd "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config"
sudo_cmd "sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config"

# Allow password authentication
if ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" | sudo_cmd "tee -a /etc/ssh/sshd_config"
fi

echo "✅ SSH configured"

# 3. Set root password (if not set)
echo ""
echo "📦 [3/4] Setting root password..."
echo "root:$PASSWORD" | sudo_cmd "chpasswd"
echo "✅ Root password set"

# 4. Start SSH service
echo ""
echo "📦 [4/4] Starting SSH service..."
sudo_cmd "service ssh start"
sudo_cmd "systemctl enable ssh" 2>/dev/null || sudo_cmd "update-rc.d ssh defaults" 2>/dev/null || true

echo "✅ SSH service started"

# Get IP address
echo ""
echo "📊 SSH Server Information:"
echo "=========================="
IP=$(hostname -I | awk '{print $1}')
echo "   IP Address: $IP"
echo "   Port: 22"
echo "   Username: root"
echo "   Password: $PASSWORD"
echo ""
echo "🔗 Connect from Windows:"
echo "   ssh root@$IP"
echo ""
echo "🔗 Connect from another machine:"
echo "   ssh root@$IP"
echo ""
echo "✅ SSH setup complete!"
echo ""
echo "⚠️  Note: Make sure Windows Firewall allows port 22"
echo "   Or use: netsh advfirewall firewall add rule name=\"WSL SSH\" dir=in action=allow protocol=TCP localport=22"

