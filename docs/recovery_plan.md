# План восстановления инфраструктуры

## 1. Отказ сервера приложений (app1 или app2)

**Симптомы:** ошибки 502/504 у части пользователей, в логах балансировщика сообщения о недоступности бэкенда.

**Автоматическое восстановление:** Nginx на lb1 с параметрами `max_fails` и `fail_timeout` исключает упавший сервер из ротации, трафик идёт на второй.

**Действия администратора:**
1. Подключиться по SSH к упавшему серверу.
2. Проверить сервисы: `systemctl status nginx php8.3-fpm`.
3. Запустить остановленные сервисы: `systemctl start nginx php8.3-fpm`.
4. Проверить доступность: `curl -I http://<IP>/`.
5. Проверить логи: `/var/log/nginx/error.log`, `journalctl -u php8.3-fpm`.

## 2. Отказ primary базы данных

**Симптомы:** приложения не подключаются к БД, ошибки SQLSTATE[08006].

**Алгоритм:**
1. Проверить статус primary: `systemctl status postgresql`.
2. Выбрать реплику для повышения (проверить отставание).
3. Повысить реплику: `pg_ctlcluster 14 main promote`.
4. Убедиться: `SELECT pg_is_in_recovery();` → должно быть `f`.
5. Обновить `LocalSettings.php` на app1/app2: заменить IP primary на IP новой реплики.
6. Перезапустить PHP-FPM: `systemctl restart php8.3-fpm`.
7. Проверить работу сайта: `curl -I https://<lb1-IP>/`.

## 3. Восстановление БД из резервной копии

1. Остановить приложения: `systemctl stop php8.3-fpm` на app1/app2.
2. Найти последний дамп: `ls -t /backups/postgres/*.sql | head -1`.
3. Пересоздать БД:
sudo -u postgres psql -c "DROP DATABASE my_wiki;"
sudo -u postgres psql -c "CREATE DATABASE my_wiki OWNER wikiuser;"
4. Восстановить: `sudo -u postgres psql -d my_wiki -f <дамп>`.
5. Запустить PHP-FPM.
6. Проверить целостность: `SELECT COUNT(*) FROM page;`.

## 4. Восстановление файлов из бэкапа

1. Найти свежий архив: `ls -t /backups/files/*.tar.gz | head -1`.
2. Восстановить: `tar -xzf <архив> -C /srv/nfs/mediawiki/`.
3. Проверить владельца: `chown -R www-data:www-data /srv/nfs/mediawiki`.

## Мониторинг

- Zabbix отслеживает доступность HTTP-сервисов (веб-сценарии).
- Prometheus/Grafana — метрики производительности.
- При срабатывании алерта администратор проверяет дашборд и действует по плану.

