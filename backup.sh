#!/bin/sh
set -eu

BACKUP_DIR=/backups
SRC_DIR=/backup-src
RETENTION_DAYS=7
DATE=$(date +%Y-%m-%d_%H%M%S)
ARCHIVE="$BACKUP_DIR/backup-$DATE.tar.gz"

tar czf "$ARCHIVE" -C "$SRC_DIR" .

find "$BACKUP_DIR" -name 'backup-*.tar.gz' -mtime "+$RETENTION_DAYS" -delete

echo "$(date -Iseconds) backup complete: $ARCHIVE"
