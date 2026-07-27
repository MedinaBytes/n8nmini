#!/bin/bash
# Start n8nmini services in tmux with Auto-Restart

AIPS_DIR="/opt/n8nmini"
SESSION="n8nmini"

echo "Starting n8nmini..."

if tmux has-session -t $SESSION 2>/dev/null; then
    echo "Session $SESSION is already running."
    exit 0
fi

mkdir -p "$AIPS_DIR/logs"

tmux new-session -d -s $SESSION -n "FastAPI"
# FastAPI with auto-restart loop
tmux send-keys -t $SESSION:0 "cd $AIPS_DIR && source venv/bin/activate && while true; do uvicorn api.main:app --host 0.0.0.0 --port 8000 >> logs/api.log 2>&1; echo 'FastAPI crashed, restarting in 5s...' >> logs/api.log; sleep 5; done" C-m

tmux new-window -t $SESSION:1 -n "n8n"
# n8n with auto-restart loop
tmux send-keys -t $SESSION:1 "cd $AIPS_DIR && while true; do export NODE_OPTIONS='--max-old-space-size=512'; n8n start >> logs/n8n.log 2>&1; echo 'n8n crashed, restarting in 5s...' >> logs/n8n.log; sleep 5; done" C-m

tmux new-window -t $SESSION:2 -n "Tunnel"
tmux send-keys -t $SESSION:2 "echo 'Cloudflare tunnel placeholder'" C-m

echo "n8nmini started in tmux session '$SESSION'."
