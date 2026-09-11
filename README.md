# Корпоративный сервис документации на MediaWiki

Отказоустойчивая инфраструктура для ведения  документации на базе MediaWiki.

##  Цель проекта

Развернуть отказоустойчивый, масштабируемый и контролируемый сервис документации с балансировкой нагрузки, репликацией БД, общим файловым хранилищем, мониторингом и автоматическим резервным копированием.

##  Архитектура

Инфраструктура состоит из 7 виртуальных машин:

| Узел | IP | Роль |
|------|----|------|
| lb1  | 192.168.0.105 | Nginx (балансировщик, HTTPS) |
| app1 | 192.168.0.106 | MediaWiki + Nginx + PHP-FPM |
| app2 | 192.168.0.108 | MediaWiki + Nginx + PHP-FPM |
| db1  | 192.168.0.109 | PostgreSQL (primary) |
| db2  | 192.168.0.110 | PostgreSQL (replica) |
| nfs  | 192.168.0.111 | NFS-сервер (общие файлы, бэкапы) |
| mon1 | 192.168.0.107 | Zabbix, Prometheus, Grafana, управление |

Схема: https://github.com/PavKole/wiki-infra-/blob/main/docs/architecture.md

## 🛠️ Стек технологий

- **ОС:** Ubuntu Server 22.04 LTS / 24.04 LTS
- **Веб:** Nginx, PHP-FPM, MediaWiki 1.42
- **БД:** PostgreSQL 14 с потоковой репликацией
- **Файловые сервисы:** NFS
- **Мониторинг:** Zabbix, Prometheus, Grafana, Node Exporter
- **Автоматизация:** Ansible, Bash
- **Сеть:** статические IP (netplan/NetworkManager), UFW, SSH-ключи

##  Структура репозитория

- `docs/` — документация (требования, архитектура, план восстановления)
- `ansible/` — playbook и inventory для автоматизации
- `scripts/` — скрипты резервного копирования и восстановления
- `configs/` — примеры конфигураций Nginx, PostgreSQL, Prometheus
- `diagrams/` — схема инфраструктуры
- `screenshots/` — скриншоты работающей системы

##  Быстрый старт

1. Разверните 7 ВМ согласно схеме.
2. Настройте SSH-доступ и статические IP (см. `docs/deployment.md`).
3. Запустите Ansible playbook: `ansible-playbook -i ansible/inventory.ini ansible/playbook.yml`
4. Проверьте доступность: `https://192.168.0.105/`

Подробнее — в [docs/deployment.md](docs/deployment.md).

