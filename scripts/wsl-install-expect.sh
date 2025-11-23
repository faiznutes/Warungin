#!/bin/bash
# Install expect di WSL
# Usage: bash scripts/wsl-install-expect.sh

echo "Installing expect in WSL..."
echo ""

sudo apt-get update
sudo apt-get install -y expect

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ expect installed successfully!"
    echo "Now you can use scripts with password automation"
else
    echo ""
    echo "❌ Failed to install expect"
    exit 1
fi

