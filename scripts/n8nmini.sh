#!/bin/bash
# n8nmini CLI (n8nmini)

AIPS_DIR="/opt/n8nmini"

command=$1
shift

case "$command" in
    start)
        bash "$AIPS_DIR/start.sh" "$@"
        ;;
    stop)
        bash "$AIPS_DIR/stop.sh" "$@"
        ;;
    status)
        tmux ls | grep n8nmini || echo "n8nmini is not running."
        ;;
    doctor)
        bash "$AIPS_DIR/doctor.sh" "$@"
        ;;
    logs)
        echo "Showing logs from $AIPS_DIR/logs/"
        tail -f "$AIPS_DIR/logs/n8n.log" "$AIPS_DIR/logs/api.log"
        ;;
    backup)
        bash "$AIPS_DIR/backup.sh" "$@"
        ;;
    restore)
        bash "$AIPS_DIR/restore.sh" "$@"
        ;;
    update)
        bash "$AIPS_DIR/update.sh" "$@"
        ;;
    install)
        echo "Please use bootstrap.sh from Termux to reinstall."
        ;;
    *)
        echo "Usage: n8nmini {start|stop|status|doctor|logs|backup|restore|update}"
        exit 1
        ;;
esac
