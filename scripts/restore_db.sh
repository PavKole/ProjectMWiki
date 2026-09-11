#!/bin/bash
# Скрипт восстановления БД из дампа
# Использование: restore_db.sh <путь_к_дампу.sql>

DUMP_FILE="${1:?Укажите путь к файлу дампа первым аргументом}"

LOG="/backups/backup.log"
log() {
    echo "$(date '+%F %T') - $1" | tee -a "$LOG"
}

DB_NAME="my_wiki"
DB_USER="wikiuser"

log "Начинаю восстановление БД $DB_NAME из $DUMP_FILE"

ssh app1 'sudo systemctl stop php8.3-fpm'
ssh app2 'sudo systemctl stop php8.3-fpm'

sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

if sudo -u postgres psql -d "$DB_NAME" -f "$DUMP_FILE"; then
    log "База $DB_NAME успешно восстановлена"
else
    log "Ошибка восстановления базы"
fi

ssh app1 'sudo systemctl start php8.3-fpm'
ssh app2 'sudo systemctl start php8.3-fpm'

log "Восстановление завершено"
