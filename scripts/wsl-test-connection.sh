#!/bin/bash
# Test koneksi dari WSL ke VPS
# Usage: bash scripts/wsl-test-connection.sh

HOST="warungin@192.168.0.101"
PASSWORD="123"

echo "Testing WSL to VPS Connection"
echo "Host: $HOST"
echo "Password: $PASSWORD"
echo ""

# Test 1: Direct connection
echo "=== Test 1: Direct SSH Connection ==="
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$HOST" "echo '✅ Connection OK!' && hostname && whoami && pwd" 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Direct connection works!"
    exit 0
fi

echo ""
echo "=== Test 2: Using expect (if available) ==="
if command -v expect &> /dev/null; then
    expect << EOF
spawn ssh -o StrictHostKeyChecking=no "$HOST" "echo '✅ Connection OK!' && hostname && whoami"
expect {
    "password:" {
        send "$PASSWORD\r"
        exp_continue
    }
    "(yes/no)?" {
        send "yes\r"
        exp_continue
    }
    eof {
        exit 0
    }
    timeout {
        puts "Connection timeout"
        exit 1
    }
}
EOF
else
    echo "expect not installed. Install with: bash scripts/wsl-install-expect.sh"
fi

echo ""
echo "If connection fails, try:"
echo "1. Check if VPS is reachable: ping 192.168.0.101"
echo "2. Use Git Bash instead (which already works)"
echo "3. Install expect: bash scripts/wsl-install-expect.sh"

