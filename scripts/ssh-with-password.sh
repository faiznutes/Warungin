#!/usr/bin/env bash
# SSH connection with password automation using expect

HOST="warungin@192.168.0.101"
PASSWORD="123"

# Try to use expect if available
if command -v expect &> /dev/null 2>&1; then
    expect << 'EOF'
set HOST "warungin@192.168.0.101"
set PASSWORD "123"
set timeout 10

spawn ssh -o StrictHostKeyChecking=no $HOST
expect {
    "password:" {
        send "$PASSWORD\r"
        exp_continue
    }
    "(yes/no)?" {
        send "yes\r"
        exp_continue
    }
    "$ " {
        send "echo 'Connected successfully'\r"
        send "hostname\r"
        send "whoami\r"
        send "exit\r"
        expect eof
    }
    "# " {
        send "echo 'Connected successfully'\r"
        send "hostname\r"
        send "whoami\r"
        send "exit\r"
        expect eof
    }
    timeout {
        puts "Connection timeout"
        exit 1
    }
    eof {
        exit 0
    }
}
EOF
else
    echo "expect is not available. Trying with plink (PuTTY) if available..."
    if command -v plink &> /dev/null 2>&1; then
        echo "$PASSWORD" | plink -ssh "$HOST" -pw "$PASSWORD" "echo 'Connected successfully'; hostname; whoami"
    else
        echo "Neither expect nor plink is available."
        echo "Please install expect or use SSH key authentication."
        echo "Or run SSH manually: ssh warungin@192.168.0.101"
        exit 1
    fi
fi

