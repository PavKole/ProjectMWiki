#!/bin/bash
## Скрипт резервного копирования базы данных PostgreSQL

DB_NAME="${1:-my_wiki}"
DB_USER="${2:-wikiuser}"
BACKUP_DIR="${3:-/backups/postgres}"

LOG_FILE="/backups/backup.log"
DUMP_FILE="${BACKUP_DIR}/${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"

log() {
    echo "$(date '+%F %T') - $1" | tee -a "$LOG_FILE"
}

mkdir -p "$BACKUP_DIR" || { log "Ошибка: не удалось создать $BACKUP_DIR"; exit 1; }

log "Создаю дамп базы $DB_NAME"

if PGPASSWORD="wiki_password" pg_dump -h localhost -U "$DB_USER" -d "$DB_NAME" -f "$DUMP_FILE"; then
    log "Дамп сохранён: $DUMP_FILE"
    find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
else
    log "Ошибка при создании дампа"
    exit 1
fi
