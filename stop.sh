#!/bin/bash
# Stop AIPhoneServer

SESSION="AIPhoneServer"

echo "Stopping AIPhoneServer..."

if tmux has-session -t $SESSION 2>/dev/null; then
    tmux kill-session -t $SESSION
    echo "Session $SESSION stopped."
else
    echo "AIPhoneServer is not running."
fi
