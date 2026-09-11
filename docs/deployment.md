# Развёртывание

## 1. Подготовка

На управляющей машине (mon1):
- Установить Ansible: `sudo apt install ansible`
- Настроить SSH-ключи: `ssh-keygen -t ed25519`, `ssh-copy-id ansible@<IP>`
- Создать inventory.ini (см. ansible/inventory.ini.example)

## 2. Настройка статических IP

На всех серверах, кроме mon1, использовать netplan:
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses: [192.168.0.XXX/24]
      routes:
        - to: default
          via: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
