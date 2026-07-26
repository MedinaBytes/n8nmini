#!/bin/bash
# Backup Utility

AIPS_DIR="/opt/AIPhoneServer"
BACKUP_DIR="$AIPS_DIR/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/aips_backup_$DATE.zip"

mkdir -p "$BACKUP_DIR"

echo "Creating backup..."
zip -r "$BACKUP_FILE" memory/ config/ workflows/ prompts/ .env > /dev/null 2>&1

if [ -f "$BACKUP_FILE" ]; then
    echo "Backup successfully created: $BACKUP_FILE"
else
    echo "Backup failed!"
fi
