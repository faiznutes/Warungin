#!/bin/bash
# Script untuk mencari path project di server

echo "=== Mencari lokasi project Warungin ==="
echo ""

# Cek beberapa lokasi umum
echo "1. Checking common project locations..."
for path in ~/Warungin ~/warungin ~/projects/Warungin /var/www/warungin /opt/warungin /home/warungin/Warungin; do
    if [ -d "$path" ]; then
        echo "   ✓ Found: $path"
        ls -la "$path" | head -5
    fi
done

echo ""
echo "2. Searching for docker-compose.yml..."
find ~ -name "docker-compose.yml" -type f 2>/dev/null | grep -i warungin | head -5

echo ""
echo "3. Searching for package.json with 'warungin'..."
find ~ -name "package.json" -type f 2>/dev/null | xargs grep -l "warungin" 2>/dev/null | head -5

echo ""
echo "4. Checking current directory..."
pwd
ls -la

echo ""
echo "5. Checking home directory..."
ls -la ~

echo ""
echo "=== Done ==="

