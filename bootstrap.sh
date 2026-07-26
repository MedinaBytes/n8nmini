#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

echo "=========================================="
echo "       AIPhoneServer Bootstrap Tool       "
echo "=========================================="

echo "[1/4] Updating Termux packages..."
pkg update -y

echo "[2/4] Installing required Termux packages..."
pkg install -y proot-distro wget curl git nano

echo "[3/4] Checking for Ubuntu installation..."
UBUNTU_ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu"

if [ ! -d "$UBUNTU_ROOTFS" ]; then
    echo "Ubuntu not found. Installing via proot-distro..."
    proot-distro install ubuntu
else
    echo "Ubuntu is already installed."
fi

echo "[4/4] Launching install.sh inside Ubuntu..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "${SCRIPT_DIR}/install.sh"

# Bind the current repository directory to /opt/AIPhoneServer inside the Ubuntu rootfs
proot-distro login ubuntu --bind "${SCRIPT_DIR}:/opt/AIPhoneServer" -- bash -c "cd /opt/AIPhoneServer && ./install.sh"

echo "=========================================="
echo "         Bootstrap Completed!             "
echo "=========================================="
