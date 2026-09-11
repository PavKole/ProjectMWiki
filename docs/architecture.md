# Архитектура


<img width="720" height="1159" alt="Диаграмма без названия drawio (4)" src="https://github.com/user-attachments/assets/971ec0a9-4d52-4d2a-99e0-ef0e4c9ae3d7" />


Инфраструктура состоит из 7 виртуальных машин, объединённых в одну подсеть 192.168.0.0/24.

| Узел  | IP              | Роль                                |
|-------|-----------------|-------------------------------------|
| lb1   | 192.168.0.105   | Балансировщик Nginx + HTTPS         |
| app1  | 192.168.0.106   | MediaWiki + Nginx + PHP-FPM         |
| app2  | 192.168.0.108   | MediaWiki + Nginx + PHP-FPM         |
| db1   | 192.168.0.109   | PostgreSQL primary                  |
| db2   | 192.168.0.110   | PostgreSQL replica                  |
| nfs   | 192.168.0.111   | NFS-сервер общих файлов и бэкапов   |
| mon1  | 192.168.0.107   | Zabbix + Prometheus + Grafana       |

## Потоки данных

1. **Пользователь → lb1** — HTTPS-запрос через балансировщик.
2. **lb1 → app1 / app2** — распределение трафика по upstream (round-robin).
3. **app1 / app2 → db1** — SQL-запросы к primary PostgreSQL.
4. **db1 → db2** — потоковая репликация WAL.
5. **app1 / app2 → nfs** — монтирование общего каталога `images` для загруженных файлов.
6. **mon1 → все узлы** — сбор метрик (Zabbix agent на порту 10050, Node Exporter на 9100).

## Компоненты по узлам

### lb1 — балансировщик
- Nginx, SSL-терминация (самоподписанный сертификат)
- Upstream с app1 и app2, параметры `max_fails`, `fail_timeout`

### app1 / app2 — приложения
- Nginx (веб-сервер)
- PHP-FPM
- MediaWiki в `/var/www/mediawiki`
- NFS-монтирование `/var/www/mediawiki/images`
- Локальный `LocalSettings.php`

### db1 / db2 — база данных
- PostgreSQL 14
- Primary (db1): приём записей, отправка WAL
- Replica (db2): чтение, приём WAL, готовность к promote
- Потоковая репликация через пользователя `repuser`

### nfs — файловый сервер
- NFS-экспорт `/srv/nfs/mediawiki`
- Хранение бэкапов в `/backups/files`

### mon1 — мониторинг
- Zabbix Server + веб-интерфейс
- Prometheus + Node Exporter (сбор метрик)
- Grafana (визуализация)
- Управление через SSH-ключи
