#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

echo "=========================================="
echo "       AIPhoneServer Bootstrap Tool       "
echo "=========================================="

echo "[1/5] Updating Termux packages..."
pkg update -y

echo "[2/5] Installing required Termux packages..."
pkg install -y proot-distro wget curl git nano

echo "[3/5] Checking for Ubuntu installation..."
UBUNTU_ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu"

if [ ! -d "$UBUNTU_ROOTFS" ]; then
    echo "Ubuntu not found. Installing via proot-distro..."
    proot-distro install ubuntu
else
    echo "Ubuntu is already installed."
fi

echo "[4/5] Launching install.sh inside Ubuntu..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "${SCRIPT_DIR}/install.sh"

# Bind the current repository directory to /opt/AIPhoneServer inside the Ubuntu rootfs
proot-distro login ubuntu --bind "${SCRIPT_DIR}:/opt/AIPhoneServer" -- bash -c "cd /opt/AIPhoneServer && ./install.sh"

echo "[5/5] Setting up Termux wrappers and widgets..."

# Create a wrapper in Termux for the aips command
cat << EOF > /data/data/com.termux/files/usr/bin/aips
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu --bind "${SCRIPT_DIR}:/opt/AIPhoneServer" -- bash -c "aips \"\\\$@\""
EOF
chmod +x /data/data/com.termux/files/usr/bin/aips

# Create the Termux:Widget shortcut
mkdir -p /data/data/com.termux/files/home/.shortcuts
cat << EOF > /data/data/com.termux/files/home/.shortcuts/Start_AIPS
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu --bind "${SCRIPT_DIR}:/opt/AIPhoneServer" -- bash -c "/opt/AIPhoneServer/scripts/aips.sh start"
EOF
chmod +x /data/data/com.termux/files/home/.shortcuts/Start_AIPS
echo "Termux wrapper and widget created successfully."

echo "=========================================="
echo "         Bootstrap Completed!             "
echo "=========================================="
