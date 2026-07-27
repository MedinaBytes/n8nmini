#!/bin/bash
# System Diagnostic Tool

echo "=== n8nmini Doctor ==="
echo "Checking dependencies..."
for cmd in node npm python3 n8n sqlite3 tmux; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "[OK] $cmd installed"
    else
        echo "[FAIL] $cmd is missing"
    fi
done

echo "Checking Memory (RAM)..."
free -m | awk 'NR==2{printf "[INFO] Total RAM: %sMB, Used: %sMB, Free: %sMB\n", $2, $3, $4}'

echo "Checking Disk Space..."
df -h / | awk 'NR==2{printf "[INFO] Total: %s, Used: %s, Free: %s\n", $2, $3, $4}'

echo "=== Diagnosis Complete ==="
