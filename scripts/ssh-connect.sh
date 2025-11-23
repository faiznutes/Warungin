#!/bin/bash
# SSH connection script with password

HOST="warungin@192.168.0.101"
PASSWORD="123"

# Check if expect is available
if ! command -v expect &> /dev/null; then
    echo "expect is not installed. Installing via package manager..."
    echo "For Git Bash on Windows, you may need to install expect manually."
    echo "Trying direct SSH connection (will prompt for password)..."
    ssh -o StrictHostKeyChecking=no "$HOST"
    exit $?
fi

# Use expect to automate password entry
expect << EOF
spawn ssh -o StrictHostKeyChecking=no "$HOST"
expect {
    "password:" {
        send "$PASSWORD\r"
        exp_continue
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    "$ " {
        interact
    }
    "# " {
        interact
    }
    timeout {
        puts "Connection timeout"
        exit 1
    }
}
EOF

