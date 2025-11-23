#!/bin/bash
# Script untuk connect ke VPS dari WSL
# Menggunakan Windows SSH key atau setup baru

HOST="warungin@192.168.0.101"
WINDOWS_SSH_KEY="/mnt/c/Users/Iz/.ssh/id_rsa_warungin"
WSL_SSH_KEY="$HOME/.ssh/id_rsa_warungin"

echo "=========================================="
echo "WSL to VPS Connection Setup"
echo "Server: $HOST"
echo "=========================================="
echo ""

# Check if Windows SSH key exists and use it
if [ -f "$WINDOWS_SSH_KEY" ]; then
    echo "✅ Found Windows SSH key: $WINDOWS_SSH_KEY"
    echo "Using Windows SSH key..."
    
    # Copy Windows key to WSL (optional, or use directly)
    mkdir -p "$HOME/.ssh"
    cp "$WINDOWS_SSH_KEY" "$WSL_SSH_KEY" 2>/dev/null
    cp "${WINDOWS_SSH_KEY}.pub" "${WSL_SSH_KEY}.pub" 2>/dev/null
    chmod 600 "$WSL_SSH_KEY" 2>/dev/null
    chmod 644 "${WSL_SSH_KEY}.pub" 2>/dev/null
    
    echo "Testing connection with Windows key..."
    ssh -i "$WSL_SSH_KEY" -o StrictHostKeyChecking=no "$HOST" "echo '✅ Connection successful!' && hostname && whoami"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "=== Setting up SSH config ==="
        SSH_CONFIG="$HOME/.ssh/config"
        mkdir -p "$HOME/.ssh"
        
        if [ ! -f "$SSH_CONFIG" ]; then
            touch "$SSH_CONFIG"
            chmod 600 "$SSH_CONFIG"
        fi
        
        if ! grep -q "Host warungin-vps" "$SSH_CONFIG"; then
            cat >> "$SSH_CONFIG" << EOF

# Warungin VPS (WSL)
Host warungin-vps
    HostName 192.168.0.101
    User warungin
    IdentityFile $WSL_SSH_KEY
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
            echo "SSH config added"
        fi
        
        echo ""
        echo "✅ Setup complete! You can now use: ssh warungin-vps"
        exit 0
    fi
fi

# If Windows key doesn't work, try direct connection
echo ""
echo "Trying direct connection (may need password)..."
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$HOST" "echo '✅ Direct connection works!' && hostname && whoami" 2>&1

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Connection failed from WSL"
    echo ""
    echo "Possible issues:"
    echo "1. WSL network cannot reach 192.168.0.101"
    echo "2. Try using Windows host IP instead"
    echo "3. Or use Git Bash which has direct network access"
    echo ""
    echo "Alternative: Use Git Bash for SSH connection"
    exit 1
fi

