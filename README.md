# OEX установщик (OEX-installer)

## Загрузить и запустить установщик

Создайте временный файл установщика

```shell
sudo apt -y install wget

wget -qO- https://github.com/s16121986/dev-cli/raw/refs/heads/main/setup.sh | bash
```

## Установка пакетов

```shell
dev-cli --install -h
```

## Добавление хостов в систему

```shell
127.0.0.1	example.online-express.local
```

- Windows - Edit `C:\Windows\system32\drivers\etc\hosts` file
- macOS - `sudo nano /private/etc/hosts`
- Linux - `sudo nano /etc/hosts`
