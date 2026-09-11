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
