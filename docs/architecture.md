# Архитектура


<img width="720" height="1159" alt="Диаграмма без названия drawio (4)" src="https://github.com/user-attachments/assets/971ec0a9-4d52-4d2a-99e0-ef0e4c9ae3d7" />


### Балансировщик (lb1)
Nginx принимает HTTPS-запросы, терминирует SSL, распределяет трафик между app1 и app2 через upstream с max_fails и fail_timeout.

### Серверы приложений (app1, app2)
Каждый сервер: Nginx + PHP-FPM + MediaWiki. Каталог images смонтирован с NFS.

### Кластер PostgreSQL (db1, db2)
Primary (db1) принимает запись, replica (db2) реплицирует через WAL. Возможен ручной failover через pg_ctlcluster promote.

### NFS-сервер (nfs)
Экспортирует /srv/nfs/mediawiki для app1 и app2. Хранит общие загруженные файлы и резервные копии.

### Мониторинг (mon1)
Zabbix для контроля доступности HTTP-сервисов, Prometheus + Grafana для метрик производительности. Node Exporter на всех узлах.

## Потоки данных

- Пользователь → lb1 (HTTPS) → app1/app2 → db1 (SQL) + nfs (файлы)
- app1/app2 → NFS (монтирование /var/www/mediawiki/images)
- db1 → db2 (потоковая репликация)
- mon1 ← все узлы (метрики через агенты и node_exporter)
