#!/usr/bin/env bash

set -euo pipefail

echo "=========================================="
echo "       n8nmini Bootstrap Tool       "
echo "=========================================="

# Check if we are already inside Ubuntu
if [ -f /etc/os-release ] && grep -qi "ubuntu" /etc/os-release; then
    echo "[*] Detected Ubuntu environment. Resuming installation from here..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y git curl wget
    REPO_URL="https://github.com/MedinaBytes/n8nmini.git"
    
    if [ ! -d '/opt/n8nmini/.git' ]; then
        rm -rf /opt/n8nmini
        git clone $REPO_URL /opt/n8nmini
    else
        cd /opt/n8nmini && git stash || true
        git pull --rebase
    fi
    cd /opt/n8nmini
    chmod +x install.sh
    ./install.sh
    exit 0
fi

echo "[1/5] Updating Termux packages..."
if [ "$(id -u)" = "0" ]; then
    apt-get update -y
else
    pkg update -y
fi

echo "[2/5] Installing required Termux packages..."
if [ "$(id -u)" = "0" ]; then
    apt-get install -y proot-distro wget curl git nano
else
    pkg install -y proot-distro wget curl git nano
fi

echo "[3/5] Checking for Ubuntu installation..."
UBUNTU_ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu"

if [ ! -d "$UBUNTU_ROOTFS" ]; then
    echo "Ubuntu not found. Installing via proot-distro..."
    proot-distro install ubuntu
else
    echo "Ubuntu is already installed."
fi

echo "[4/5] Launching setup inside Ubuntu..."
REPO_URL="https://github.com/MedinaBytes/n8nmini.git"

proot-distro login ubuntu -- bash -c "
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y git curl wget
if [ ! -d '/opt/n8nmini/.git' ]; then
    rm -rf /opt/n8nmini
    git clone \$REPO_URL /opt/n8nmini
else
    cd /opt/n8nmini && git stash || true
    git pull --rebase
fi
cd /opt/n8nmini
chmod +x install.sh
./install.sh
"

echo "[5/5] Setting up Termux wrappers and widgets..."

# Create a wrapper in Termux for the n8nmini command
cat << 'EOF' > /data/data/com.termux/files/usr/bin/n8nmini
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu -- bash -c "/opt/n8nmini/scripts/n8nmini.sh \"\$@\""
EOF
chmod +x /data/data/com.termux/files/usr/bin/n8nmini

# Create the Termux:Widget shortcut
mkdir -p /data/data/com.termux/files/home/.shortcuts
cat << 'EOF' > /data/data/com.termux/files/home/.shortcuts/Start_n8nmini
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu -- bash -c "/opt/n8nmini/scripts/n8nmini.sh start"
EOF
chmod +x /data/data/com.termux/files/home/.shortcuts/Start_n8nmini
echo "Termux wrapper and widget created successfully."

echo "=========================================="
echo "         Bootstrap Completed!             "
echo "=========================================="
