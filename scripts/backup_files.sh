#!/bin/bash
# Скрипт резервного копирования файлов MediaWiki
# Использование: backup_files.sh [ИСХОДНАЯ_ДИРЕКТОРИЯ] [КАТАЛОГ_ДЛЯ_БЭКАПОВ]

SOURCE_DIR="${1:-/srv/nfs/mediawiki}"
BACKUP_DIR="${2:-/backups/files}"
LOG_FILE="/backups/backup.log"

log() {
    echo "$(date '+%F %T') - $1" | tee -a "$LOG_FILE"
}

mkdir -p "$BACKUP_DIR" || { log "Ошибка: не удалось создать $BACKUP_DIR"; exit 1; }

ARCHIVE="${BACKUP_DIR}/mediawiki_files_$(date +%Y%m%d_%H%M%S).tar.gz"
log "Начинаю архивацию $SOURCE_DIR в $ARCHIVE"

if tar -czf "$ARCHIVE" -C "$SOURCE_DIR" .; then
    log "Архив $ARCHIVE создан успешно"
    find "$BACKUP_DIR" -name "mediawiki_files_*.tar.gz" -mtime +7 -delete
else
    log "Ошибка при создании архива"
    exit 1
fi
