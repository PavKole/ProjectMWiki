# План восстановления

## 1. Отказ сервера приложений (app1/app2)

**Симптомы:** ошибки 502/504, недоступность бэкенда в логах lb1.

**Автоматическое восстановление:** Nginx исключает упавший сервер из upstream.

**Действия:**
1. `ssh app1` (или перезагрузка ВМ).
2. `sudo systemctl status nginx php8.3-fpm`.
3. `sudo systemctl start nginx php8.3-fpm`.
4. Проверка: `curl -I http://192.168.0.106/`.

## 2. Отказ primary БД

**Симптомы:** ошибки SQLSTATE[08006], сайт недоступен.

**Действия:**
1. Проверить `systemctl status postgresql` на db1.
2. Повысить реплику: `ssh db2 'sudo -u postgres pg_ctlcluster 14 main promote'`.
3. Проверить: `SELECT pg_is_in_recovery();` → f.
4. Обновить LocalSettings.php на app1/app2: заменить IP на новый primary.
5. Перезапустить PHP-FPM.
6. Проверить сайт.
7. Восстановить старый primary как реплику через `pg_basebackup`.

## 3. Восстановление файлов из бэкапа

1. Найти свежий архив: `ls -t /backups/files/mediawiki_files_*.tar.gz | head -1`.
2. Распаковать: `sudo tar -xzf <архив> -C /srv/nfs/mediawiki/`.
3. Проверить наличие файлов.

## 4. Восстановление БД из дампа

1. Остановить PHP-FPM на app1/app2.
2. `sudo -u postgres psql -c "DROP DATABASE my_wiki;"`
3. `sudo -u postgres psql -c "CREATE DATABASE my_wiki OWNER wikiuser;"`
4. `sudo -u postgres psql -d my_wiki -f /backups/postgres/<дамп>.sql`
5. Запустить PHP-FPM.
6. Проверить сайт.

## Мониторинг

Все серверы отправляют метрики в Prometheus (node_exporter) и Zabbix. При алерте проверить дашборд и действовать по сценарию.


<img width="2559" height="1439" alt="image" src="https://github.com/user-attachments/assets/4a1fc269-0adf-4632-9d3b-0c5b4953eb67" />
<img width="2459" height="1389" alt="Снимок экрана 2026-09-11 064241" src="https://github.com/user-attachments/assets/b8230073-ecfb-4b0c-8706-1cd841cd1d99" />

<img width="2467" height="1281" alt="image" src="https://github.com/user-attachments/assets/c5eab761-583b-44ea-9a9f-4751c1dc4ac1" />
