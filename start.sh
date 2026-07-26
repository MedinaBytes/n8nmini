#!/bin/bash
# Start AIPhoneServer services in tmux

AIPS_DIR="/opt/AIPhoneServer"
SESSION="AIPhoneServer"

echo "Starting AIPhoneServer..."

if tmux has-session -t $SESSION 2>/dev/null; then
    echo "Session $SESSION is already running."
    exit 0
fi

mkdir -p "$AIPS_DIR/logs"

tmux new-session -d -s $SESSION -n "FastAPI"
tmux send-keys -t $SESSION:0 "cd $AIPS_DIR && source venv/bin/activate && uvicorn api.main:app --host 0.0.0.0 --port 8000 > logs/api.log 2>&1" C-m

tmux new-window -t $SESSION:1 -n "n8n"
tmux send-keys -t $SESSION:1 "cd $AIPS_DIR && n8n start > logs/n8n.log 2>&1" C-m

tmux new-window -t $SESSION:2 -n "Tunnel"
tmux send-keys -t $SESSION:2 "echo 'Cloudflare tunnel placeholder'" C-m

echo "AIPhoneServer started in tmux session '$SESSION'."
