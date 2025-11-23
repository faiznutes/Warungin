#!/bin/bash
# Script untuk check koneksi VPS
# Usage: bash scripts/check-vps-connection.sh

HOST="192.168.0.101"
USER="warungin"
FULL_HOST="$USER@$HOST"

echo "=========================================="
echo "Checking VPS Connection"
echo "Host: $FULL_HOST"
echo "=========================================="
echo ""

# Test 1: Ping
echo "=== Test 1: Ping ==="
ping -c 3 $HOST 2>/dev/null || ping -c 3 $HOST
PING_RESULT=$?

if [ $PING_RESULT -eq 0 ]; then
    echo "✅ Ping successful"
else
    echo "❌ Ping failed - VPS may be down or unreachable"
fi
echo ""

# Test 2: Port 22 (SSH)
echo "=== Test 2: SSH Port (22) ==="
if command -v nc &> /dev/null || command -v netcat &> /dev/null; then
    timeout 3 nc -zv $HOST 22 2>&1 || timeout 3 netcat -zv $HOST 22 2>&1
else
    timeout 3 bash -c "echo > /dev/tcp/$HOST/22" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Port 22 is open"
    else
        echo "❌ Port 22 is closed or unreachable"
    fi
fi
echo ""

# Test 3: SSH Connection (with key)
echo "=== Test 3: SSH Connection (with key) ==="
if [ -f ~/.ssh/id_rsa_warungin ]; then
    ssh -i ~/.ssh/id_rsa_warungin -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$FULL_HOST" "echo '✅ SSH key connection works!' && hostname && whoami" 2>&1
    KEY_RESULT=$?
    if [ $KEY_RESULT -eq 0 ]; then
        echo "✅ SSH key authentication successful"
    else
        echo "❌ SSH key authentication failed"
    fi
else
    echo "⚠️  SSH key not found at ~/.ssh/id_rsa_warungin"
fi
echo ""

# Test 4: SSH Connection (direct)
echo "=== Test 4: SSH Connection (direct) ==="
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$FULL_HOST" "echo '✅ Direct connection works!' && hostname && whoami" 2>&1
DIRECT_RESULT=$?

if [ $DIRECT_RESULT -eq 0 ]; then
    echo "✅ Direct SSH connection successful"
elif [ $DIRECT_RESULT -eq 255 ]; then
    echo "❌ Connection timeout or refused"
    echo "Possible causes:"
    echo "  - VPS is down"
    echo "  - Firewall blocking port 22"
    echo "  - Network routing issue"
    echo "  - SSH service not running on VPS"
else
    echo "❌ SSH connection failed (exit code: $DIRECT_RESULT)"
fi
echo ""

# Test 5: SSH Config alias
echo "=== Test 5: SSH Config Alias ==="
if [ -f ~/.ssh/config ] && grep -q "warungin-vps" ~/.ssh/config; then
    ssh -o ConnectTimeout=5 warungin-vps "echo '✅ SSH config alias works!' && hostname" 2>&1
    CONFIG_RESULT=$?
    if [ $CONFIG_RESULT -eq 0 ]; then
        echo "✅ SSH config alias works"
    else
        echo "❌ SSH config alias failed"
    fi
else
    echo "⚠️  SSH config alias 'warungin-vps' not found"
fi
echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
if [ $PING_RESULT -eq 0 ]; then
    echo "✅ Network: Reachable"
else
    echo "❌ Network: Unreachable"
fi

if [ $DIRECT_RESULT -eq 0 ] || [ $KEY_RESULT -eq 0 ]; then
    echo "✅ SSH: Working"
    echo ""
    echo "You can connect using:"
    if [ $KEY_RESULT -eq 0 ]; then
        echo "  ssh -i ~/.ssh/id_rsa_warungin $FULL_HOST"
    fi
    if [ -f ~/.ssh/config ] && grep -q "warungin-vps" ~/.ssh/config; then
        echo "  ssh warungin-vps"
    fi
    echo "  ssh $FULL_HOST"
else
    echo "❌ SSH: Not working"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check if VPS is running: ping $HOST"
    echo "2. Check SSH service on VPS (if you have access)"
    echo "3. Check firewall rules"
    echo "4. Verify network connectivity"
fi
echo ""

