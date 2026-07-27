#!/bin/bash

# n8nmini - Phase 4
# install.sh
# Purpose: Installs all dependencies inside the Ubuntu proot-distro environment.
# It expects to be run in /opt/n8nmini

set -euo pipefail

echo "=========================================="
echo "    n8nmini Ubuntu Installer        "
echo "=========================================="

echo "[1/8] Updating Ubuntu and installing base utilities..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y curl wget git nano tmux sqlite3 zip unzip ca-certificates software-properties-common build-essential openssh-server

echo "[1.5/8] Configuring SSH for remote access..."
mkdir -p /var/run/sshd
# Run SSH on port 2222 so it doesn't conflict with Termux's native sshd
sed -i 's/^#*Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
# Default password for root so the user can login
echo "root:admin" | chpasswd
service ssh start || /usr/sbin/sshd
echo "SSH configured on port 2222 (Login: root / admin)."

echo "[2/8] Installing Node.js LTS..."
if ! command -v node > /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
else
    echo "Node.js already installed: $(node -v)"
fi

echo "[3/8] Installing Python 3 and venv..."
apt-get install -y python3 python3-pip python3-venv

echo "[4/8] Installing n8n..."
if ! command -v n8n > /dev/null; then
    npm install -g n8n --omit=dev --no-fund --no-audit || { echo "Retrying n8n install..."; npm cache clean --force; npm install -g n8n --omit=dev --no-fund --no-audit; }
else
    echo "n8n already installed: $(n8n --version)"
fi

echo "[5/8] Setting up Python Environment for FastAPI..."
cd /opt/n8nmini
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
# Activate venv and install requirements
source venv/bin/activate
pip install --upgrade pip
pip install fastapi uvicorn pydantic python-dotenv

echo "[6/8] Generating .env.example..."
cat << 'EOF' > .env.example
# n8nmini Environment Variables

# n8n Settings
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_HOST=0.0.0.0
N8N_LISTEN_ADDRESS=0.0.0.0
WEBHOOK_URL=http://localhost:5678/
GENERIC_TIMEZONE=UTC

# FastAPI Settings
API_PORT=8000
API_HOST=0.0.0.0
EOF

if [ ! -f .env ]; then
    cp .env.example .env
fi

echo "[7/8] Preparing CLI tool structure..."
# We generate a placeholder for the n8nmini command which will be fully implemented in Phase 5
if [ ! -f "scripts/n8nmini.sh" ]; then
    cat << 'EOF' > scripts/n8nmini.sh
#!/bin/bash
echo "n8nmini CLI not fully implemented yet. Run Phase 5."
EOF
    chmod +x scripts/n8nmini.sh
fi

# Symlink it so it's available globally in Ubuntu
ln -sf /opt/n8nmini/scripts/n8nmini.sh /usr/local/bin/n8nmini

echo "[8/8] Verifying Installation..."
echo "------------------------------------------"
node -v | sed 's/^/Node.js: /'
npm -v | sed 's/^/npm: /'
python3 --version | sed 's/^/Python: /'
echo "n8n: $(n8n --version)"
echo "SQLite: $(sqlite3 --version | awk '{print $1}')"
echo "------------------------------------------"

echo "=========================================="
echo "    Installation Successfully Completed!  "
echo "=========================================="

