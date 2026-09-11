# Мониторинг

## Zabbix — доступность сервисов

- Установлен на mon1 (Zabbix Server + Frontend)
- Zabbix-агенты на всех узлах (порт 10050)
- Веб-сценарии для проверки кода ответа 200 на app1 и app2
- Триггеры срабатывают при `last(/appX/web.test.fail[...])<>0`

## Prometheus + Grafana — метрики производительности

- Prometheus на mon1 (порт 9090)
- Node Exporter на всех узлах (порт 9100)
- Сбор метрик: CPU, память, диск, сеть
- Grafana на mon1 (порт 3000) с дашбордом Node Exporter (ID 1860)

## Алерты

- Zabbix: оповещения при недоступности HTTP-сервисов
- Grafana: визуальные алерты при превышении порогов CPU/RAM

## Проверка

- Открыть `http://<mon1-IP>/zabbix` — веб-интерфейс Zabbix
- Открыть `http://<mon1-IP>:3000` — Grafana
- Открыть `http://<mon1-IP>:9090/targets` — статус сбора метрик Prometheus

<img width="2550" height="1271" alt="image" src="https://github.com/user-attachments/assets/78df0422-46c6-40df-b4ea-466de5fed709" />
<img width="2559" height="1439" alt="image" src="https://github.com/user-attachments/assets/4a1fc269-0adf-4632-9d3b-0c5b4953eb67" />
<img width="2459" height="1389" alt="Снимок экрана 2026-09-11 064241" src="https://github.com/user-attachments/assets/b8230073-ecfb-4b0c-8706-1cd841cd1d99" />

<img width="2467" height="1281" alt="image" src="https://github.com/user-attachments/assets/c5eab761-583b-44ea-9a9f-4751c1dc4ac1" />
