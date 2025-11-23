#!/bin/bash
# Script untuk setup SSH key authentication ke VPS
# Usage: bash scripts/setup-ssh-key.sh

HOST="warungin@192.168.0.101"
PASSWORD="123"
SSH_KEY_NAME="id_rsa_warungin"
SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"

echo "=========================================="
echo "Setup SSH Key Authentication"
echo "Server: $HOST"
echo "=========================================="
echo ""

# Check if key already exists
if [ -f "$SSH_KEY_PATH" ]; then
    echo "SSH key already exists: $SSH_KEY_PATH"
    read -p "Do you want to use existing key? (y/n): " use_existing
    if [ "$use_existing" != "y" ]; then
        echo "Generating new SSH key..."
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "warungin-vps"
    fi
else
    echo "Generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "warungin-vps"
fi

echo ""
echo "=== Copying public key to server ==="
echo "You will be prompted for password: $PASSWORD"
echo ""

# Try using ssh-copy-id, if not available, use manual method
if command -v ssh-copy-id &> /dev/null; then
    ssh-copy-id -i "$SSH_KEY_PATH.pub" "$HOST"
else
    # Manual method
    cat "$SSH_KEY_PATH.pub" | ssh -o StrictHostKeyChecking=no "$HOST" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
fi

echo ""
echo "=== Testing SSH connection ==="
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$HOST" "echo 'SSH key authentication successful!' && hostname && whoami"

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Setting up SSH config ==="
    
    # Create or update SSH config
    SSH_CONFIG="$HOME/.ssh/config"
    mkdir -p "$HOME/.ssh"
    
    if [ ! -f "$SSH_CONFIG" ]; then
        touch "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
    fi
    
    # Check if config already exists
    if ! grep -q "Host warungin-vps" "$SSH_CONFIG"; then
        cat >> "$SSH_CONFIG" << EOF

# Warungin VPS
Host warungin-vps
    HostName 192.168.0.101
    User warungin
    IdentityFile $SSH_KEY_PATH
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
        echo "SSH config added to $SSH_CONFIG"
    else
        echo "SSH config already exists"
    fi
    
    echo ""
    echo "=========================================="
    echo "✅ SSH Key Setup Complete!"
    echo "=========================================="
    echo ""
    echo "You can now connect without password using:"
    echo "  ssh warungin-vps"
    echo ""
    echo "Or using the key directly:"
    echo "  ssh -i $SSH_KEY_PATH $HOST"
    echo ""
else
    echo ""
    echo "❌ SSH key authentication failed!"
    echo "Please check the error above and try again."
    exit 1
fi

