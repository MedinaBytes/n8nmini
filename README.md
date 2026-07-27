# n8nmini 📱

Transform an old Android phone into a lightweight, reliable, 24/7 AI Automation Node.

**Philosophy:**
> The phone is an automation node, not an AI server.

Heavy AI inference (LLMs, transcription) should be offloaded to OpenAI, Claude, Gemini, or a local PC running Ollama. This server connects to them, manages workflows (n8n), handles state memory (SQLite + FastAPI), and orchestrates tasks.

**Target Hardware:**
- Legacy Android Phones (ARM64)
- 2–4 GB RAM
- Termux + Ubuntu (via `proot-distro`)

---

## ⚡ Features (Version 1.0)
- **Ultra-Lightweight**: Uses SQLite, built-in processes, and tmux. Consumes roughly ~300-500 MB RAM.
- **FastAPI Brain**: Exposes an API to interact with your AI memory and tasks.
- **n8n Orchestration**: Runs scheduled workflows and webhooks.
- **No Heavy Containers**: No Docker, no systemd, no Postgres, no Redis.
- **One-Command CLI**: Includes the `n8nmini` global command to manage everything seamlessly.

---

## 🛠️ Installation

Just three commands to get a fully working AI orchestration node on your phone!

1. **Install Termux** from F-Droid (do not use the Google Play version).
2. Open Termux and run:
```bash
pkg update && pkg install git -y
git clone https://github.com/MedinaBytes/n8nmini.git n8nmini
cd n8nmini
bash bootstrap.sh
```

The bootstrap script will automatically:
- Install Ubuntu via `proot-distro`
- Run `install.sh` inside Ubuntu
- Configure Node.js LTS, Python, n8n, FastAPI, SQLite, and tmux.

---

## 💻 How to Use (`n8nmini` CLI)

Once installed, use the `n8nmini` global command from anywhere inside the Ubuntu environment:

- `n8nmini start` - Starts FastAPI, n8n, and Cloudflare Tunnel in a tmux session.
- `n8nmini stop` - Gracefully stops the services.
- `n8nmini status` - Shows running services and tmux windows.
- `n8nmini doctor` - Checks for dependencies, available RAM, and configuration issues.
- `n8nmini logs` - Views logs for the running services.
- `n8nmini backup` - Backs up your workflows, memory database, and configurations to a compressed archive.
- `n8nmini restore <file>` - Restores a previously created backup.
- `n8nmini update` - Pulls the latest repository updates and refreshes dependencies.

---

## 📂 Project Structure

```text
n8nmini/
├── bootstrap.sh    # Termux environment setup
├── install.sh      # Ubuntu environment setup
├── start.sh        # Service startup
├── stop.sh         # Service shutdown
├── doctor.sh       # System diagnostic tool
├── backup.sh       # Backup utility
├── restore.sh      # Restore utility
├── update.sh       # Update utility
├── config/         # Configuration files
├── api/            # FastAPI application (main.py)
├── memory/         # SQLite memory database (memory.db)
├── workflows/      # Exported n8n workflows
├── prompts/        # AI System prompts
├── logs/           # Service output logs
└── scripts/        # Internal CLI logic (n8nmini.sh)
```

---

## 🚀 Services

When started via `n8nmini start`, n8nmini spins up **3 tmux windows** under the `n8nmini` session to keep RAM usage low:
1. **FastAPI**: The brain (port `8000`)
2. **n8n**: The orchestrator (port `5678`)
3. **Cloudflare Tunnel (Optional)**: Secure internet access

You can access n8n locally via your phone's browser or from your PC on the same network:
`http://<phone-ip>:5678`
