# OEX установщик (OEX-installer)

## Подготовка рабочей среды

- [Инструкция по установке Wsl](./docs/wsl.md) (Для работы в Windows)

## Загрузить и запустить установщик

Создайте временный файл установщика

```shell
touch /tmp/setup.sh && chmod u+x /tmp/setup.sh && nano /tmp/setup.sh
```

скопируйте в него
[содержимое из репозитория](https://gitlab.online-express.ru/oex/dev-tools/cli-tools/-/blob/main/setup.sh),
сохраните (Ctrl+X) и запустите:

[//]: # (curl --request GET --header 'PRIVATE-TOKEN: $YOUR_GITLAB_TOKEN' \)
[//]: # (  'https://gitlab.online-express.ru/api/v4/projects/540/repository/files/setup.sh/raw?ref=main' \)
[//]: # (  --output /tmp/setup.sh)

```shell
/tmp/setup.sh && rm /tmp/setup.sh
```

## 4. Установка проектов

```shell
dev-cli clone <project>
dev-cli clone -h
```

### Включение/Отключение проектов

```shell
dev-cli up <project>
dev-cli down <project>

# Для режима докера можно использовать запуск и остановку всех текущих проектов
dev-cli up
dev-cli down
```

## 5. Проверить что все работает

Открыть в браузере склонированный проект.

## Дополнительно

### Установка дополнительных пакетов

```shell
dev-cli --install -h
```

> **Важно!** После установки некотрых сервисов (напримаер Docker), пожет потребоваться перезагрузка. Для перезапуска Wsl
> см. [инструкцию](./docs/wsl.md)

- [Настройка XDebug](https://wiki.yandex.ru/dev/faq/xdebug/)

### Добавление хостов в систему

```shell
127.0.0.1	example.online-express.local
```

- Windows - Edit `C:\Windows\system32\drivers\etc\hosts` file
- macOS - `sudo nano /private/etc/hosts`
- Linux - `sudo nano /etc/hosts`
