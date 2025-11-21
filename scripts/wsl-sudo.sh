#!/bin/bash
# Helper script untuk menjalankan perintah sudo di WSL dengan password
# Usage: ./scripts/wsl-sudo.sh "command to run"

PASSWORD="123"

if [ -z "$1" ]; then
    echo "Usage: ./scripts/wsl-sudo.sh \"command to run\""
    echo "Example: ./scripts/wsl-sudo.sh \"apt-get update\""
    exit 1
fi

echo "$PASSWORD" | sudo -S bash -c "$1"

