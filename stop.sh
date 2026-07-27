#!/bin/bash
# Stop n8nmini

SESSION="n8nmini"

echo "Stopping n8nmini..."

if tmux has-session -t $SESSION 2>/dev/null; then
    tmux kill-session -t $SESSION
    echo "Session $SESSION stopped."
else
    echo "n8nmini is not running."
fi
