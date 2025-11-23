#!/bin/bash
# Script untuk test koneksi SSH
# Usage: bash scripts/test-ssh-connection.sh

HOST="warungin@192.168.0.101"
SSH_KEY_PATH="$HOME/.ssh/id_rsa_warungin"

echo "Testing SSH Connection to $HOST"
echo ""

# Test 1: Try with SSH key
if [ -f "$SSH_KEY_PATH" ]; then
    echo "=== Test 1: SSH Key Authentication ==="
    ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$HOST" "echo '✅ SSH key works!' && hostname && whoami && pwd"
    if [ $? -eq 0 ]; then
        echo "✅ SSH key authentication successful!"
        exit 0
    fi
    echo ""
fi

# Test 2: Try with SSH config alias
echo "=== Test 2: SSH Config Alias ==="
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 warungin-vps "echo '✅ SSH config works!' && hostname && whoami && pwd" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ SSH config alias works!"
    exit 0
fi
echo ""

# Test 3: Try direct connection (will prompt password)
echo "=== Test 3: Direct Connection (password required) ==="
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$HOST" "echo '✅ Direct connection works!' && hostname && whoami && pwd"
if [ $? -eq 0 ]; then
    echo "✅ Direct connection works (but requires password)"
    echo ""
    echo "💡 Tip: Run 'bash scripts/setup-ssh-key.sh' to setup passwordless login"
    exit 0
else
    echo "❌ Connection failed!"
    exit 1
fi

