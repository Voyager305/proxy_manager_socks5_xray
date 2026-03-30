# proxy_manager_socks5_xray

**Локальный SOCKS5 прокси-менеджер на базе Xray-core.**

Запускает [Xray-core](https://github.com/XTLS/Xray-core) как дочерний процесс и поднимает локальный SOCKS5-порт. Любое приложение с поддержкой SOCKS5 (браузеры, мессенджеры, CLI) может им пользоваться. Без GUI, без root — только Python и один скрипт.

Поддерживает протокол **VLESS + Reality** — современный и устойчивый к блокировкам.

**[English version](README.md)**

---

## Принцип работы

Схема работы:

`Приложение (Telegram/браузер/CLI) -> локальный SOCKS5 127.0.0.1:2080 -> Xray (на вашем ПК) -> VLESS+Reality сервер -> интернет`

Что это означает на практике:

1. Вы запускаете `app.py`.
2. Скрипт ищет бинарник `xray` (в папке проекта или в `PATH`) и загружает `client_config.json`.
3. Если указан `--vless`, скрипт сначала разбирает VLESS-ссылку и на ее основе автоматически формирует рабочий `client_config.json`.
4. Скрипт запускает Xray как отдельный процесс и передает ему команду `run -c client_config.json`.
5. Xray открывает **локальный SOCKS5-вход** (`inbound`) на `127.0.0.1:2080` (или на порт из вашего конфига).
6. Любое приложение, в котором вы прописали этот SOCKS5, отправляет сетевые запросы в локальный Xray.
7. Дальше Xray применяет правила маршрутизации:
   - адреса из `geoip:private` идут напрямую через `direct` (локальная сеть, приватные диапазоны);
   - остальной трафик уходит через `proxy` на ваш удаленный VLESS + Reality сервер.
8. На удаленном сервере запрос выходит в интернет и ответ возвращается тем же путем обратно в приложение.
9. При `Ctrl+C` скрипт корректно завершает процесс Xray, чтобы не оставлять «висячий» локальный прокси.

Важно: этот скрипт не «перехватывает» весь системный трафик сам по себе. Через него идет только трафик тех приложений, где явно указан SOCKS5 `127.0.0.1:2080`.

## Возможности

- Локальный SOCKS5 прокси для любого приложения (браузеры, Telegram и т.д.)
- Поддержка VLESS + Reality (Xray-core 26+)
- Работает на **macOS**, **Linux** и **Windows**
- Запуск одной командой, без установки
- Совместим с Telethon, Pyrogram и любыми SOCKS5-клиентами

## Скачивание

Выберите архив для вашей ОС:

| Платформа | Архив | Архитектура |
|-----------|-------|-------------|
| macOS | `proxy_manager_socks5_xray_mac_arm64.zip` | ARM64 (Apple Silicon) |
| macOS | `proxy_manager_socks5_xray_mac_amd64.zip` | x86-64 (Intel) |
| Linux | `proxy_manager_socks5_xray_linux_amd64.zip` | x86-64 (amd64) |
| Windows | `proxy_manager_socks5_xray_win_amd64.zip` | x86-64 (amd64) |

Каждый архив — самодостаточный пакет: скрипт + бинарник Xray + geo-файлы.

## Требования

- **Python 3.7+**
- Xray-core уже включён в каждый пакет

## Быстрый старт

### 1. Выберите способ настройки (рекомендуется A)

Есть два равноправных варианта:

- **A: через VLESS-ссылку (проще и быстрее)** — конфиг создастся автоматически при запуске.
- **B: вручную через `client_config.json`** — если удобнее контролировать JSON самостоятельно.

### 2. Запустите выбранным способом

**Способ A — VLESS-ссылка (рекомендуется):**

```bash
python3 app.py --vless "vless://UUID@HOST:PORT?type=tcp&security=reality&pbk=KEY&fp=chrome&sni=SNI&sid=SID&flow=xtls-rprx-vision#name"
```

Конфиг сгенерируется и сохранится. При следующем запуске достаточно:

```bash
python3 app.py
```

**Способ B — ручной JSON-конфиг:**

Отредактируйте `client_config.json` в папке для вашей ОС, подставив данные от вашего VLESS Reality сервера:

| Поле | Описание |
|------|----------|
| `address` | IP-адрес или домен сервера |
| `port` | Порт (обычно 443) |
| `id` | UUID пользователя |
| `flow` | `xtls-rprx-vision` для Reality |
| `serverName` | SNI (например, `google.com`) |
| `password` | Публичный ключ Reality |
| `shortId` | Short ID (hex, до 16 символов) |

<details>
<summary><b>Как заполнить из VLESS-ссылки</b></summary>

Если у вас есть ссылка вида `vless://uuid@host:port?...`, поля заполняются так:

```
vless://UUID@ADDRESS:PORT?type=tcp&security=reality&pbk=PASSWORD&fp=chrome&sni=SERVERNAME&sid=SHORTID&flow=xtls-rprx-vision#название
         │       │    │                                  │                       │            │
         ↓       ↓    ↓                                  ↓                       ↓            ↓
        id   address  port                            password              serverName      shortId
```

</details>

<details>
<summary><b>Пример client_config.json</b></summary>

```json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 2080,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": { "auth": "noauth", "udp": true },
      "tag": "socks-in"
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "YOUR_SERVER_IP_OR_DOMAIN",
            "port": 443,
            "users": [
              {
                "id": "YOUR-UUID-HERE",
                "encryption": "none",
                "flow": "xtls-rprx-vision"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "fingerprint": "chrome",
          "serverName": "google.com",
          "password": "YOUR_PUBLIC_KEY_HERE",
          "shortId": "YOUR_SHORT_ID"
        }
      },
      "tag": "proxy"
    },
    {
      "protocol": "freedom",
      "tag": "direct"
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "direct"
      }
    ]
  }
}
```

</details>

**Запуск для macOS / Linux:**

```bash
cd proxy_manager_socks5_xray_mac_arm64    # или proxy_manager_socks5_xray_mac_amd64 / proxy_manager_socks5_xray_linux_amd64
python3 app.py
```

> На Linux может потребоваться: `chmod +x xray-core/xray`

**Windows:**

```cmd
cd proxy_manager_socks5_xray_win_amd64
python app.py
```

Прокси будет слушать **127.0.0.1:2080** (или порт из конфига). Укажите этот адрес в любом приложении с поддержкой SOCKS5.

## Опции запуска

```bash
python3 app.py                          # запуск с настройками по умолчанию
python3 app.py -v "vless://..."         # запуск из VLESS-ссылки (сохраняет конфиг)
python3 app.py -c my_config.json        # другой конфиг
python3 app.py -x /usr/local/bin/xray   # свой путь к Xray
python3 app.py -q                        # тихий режим (без логов)
```

| Флаг | Описание |
|------|----------|
| `-v`, `--vless` | VLESS URI — автоматически генерирует и сохраняет конфиг |
| `-c`, `--config` | Путь к JSON-конфигу (по умолчанию `client_config.json`) |
| `-x`, `--xray` | Путь к бинарнику Xray |
| `-q`, `--quiet` | Минимальный вывод |

### 3. Быстрая проверка

Проверьте, что трафик действительно идет через локальный SOCKS5:

```bash
curl --socks5 127.0.0.1:2080 https://api.telegram.org
```

Если возвращается JSON, прокси работает корректно.

## Использование с другими приложениями

Прокси — это обычный **SOCKS5** сервер на `127.0.0.1:2080` (без авторизации). Использовать можно с:

- **Браузерами** — настройка системного или браузерного прокси: SOCKS5, хост `127.0.0.1`, порт `2080`
- **curl / wget** — например: `curl --socks5 127.0.0.1:2080 https://example.com`
- **Любым приложением** с поддержкой SOCKS5 (мессенджеры, IDE и т.д.)

## Использование с Telegram

Как настроить:

**Telegram Desktop:**  
**Настройки → Продвинутые настройки → Настройки прокси сервера → Добавить прокси**

| Параметр | Значение |
|----------|----------|
| Тип | SOCKS5 |
| Хост | `127.0.0.1` |
| Порт | `2080` |

### Telethon / Pyrogram

Запустите прокси в одном терминале, бот — в другом:

```python
# Telethon
from telethon import TelegramClient
import socks

client = TelegramClient(
    "session",
    api_id=YOUR_API_ID,
    api_hash="YOUR_API_HASH",
    proxy=(socks.SOCKS5, "127.0.0.1", 2080)
)
```

```python
# Pyrogram
from pyrogram import Client

app = Client(
    "session",
    api_id=YOUR_API_ID,
    api_hash="YOUR_API_HASH",
    proxy=dict(scheme="socks5", hostname="127.0.0.1", port=2080)
)
```

## Структура проекта

Ниже показана логическая структура репозитория (имя корневой папки может отличаться):

```
proxy_manager_socks5_xray/
│
├── README.md
├── README_RU.md
├── LICENSE
│
├── proxy_manager_socks5_xray_mac_arm64/      # macOS (ARM64 / Apple Silicon)
│   ├── app.py
│   ├── client_config.json
│   ├── README.md
│   └── xray-core/
│       ├── xray
│       ├── LICENSE-Xray.txt   # MPL 2.0
│       ├── geoip.dat
│       └── geosite.dat
│
├── proxy_manager_socks5_xray_mac_amd64/      # macOS (x86-64 / Intel)
│   ├── app.py
│   ├── client_config.json
│   ├── README.md
│   └── xray-core/
│       ├── xray
│       ├── LICENSE-Xray.txt   # MPL 2.0
│       ├── geoip.dat
│       └── geosite.dat
│
├── proxy_manager_socks5_xray_linux_amd64/   # Linux (x86-64 / amd64)
│   ├── app.py
│   ├── client_config.json
│   ├── README.md
│   └── xray-core/
│       ├── xray
│       ├── LICENSE-Xray.txt   # MPL 2.0
│       ├── geoip.dat
│       └── geosite.dat
│
└── proxy_manager_socks5_xray_win_amd64/     # Windows (x86-64 / amd64)
    ├── app.py
    ├── client_config.json
    ├── README.md
    └── xray-core/
        ├── xray.exe
        ├── LICENSE-Xray.txt   # MPL 2.0
        ├── wintun.dll
        ├── geoip.dat
        └── geosite.dat
```

## FAQ

**В: macOS пишет «Файл «xray» не был открыт», Apple не может проверить разработчика. Что делать?**  
Бинарник Xray не подписан Apple (это нормально для open-source). Разрешить запуск можно так:
- **Вариант 1:** Нажмите «Готово», затем откройте **Системные настройки → Конфиденциальность и безопасность** — внизу появится кнопка «Всё равно открыть» для этого приложения.
- **Вариант 2:** В терминале из папки с проектом выполните:
  ```bash
  xattr -d com.apple.quarantine xray-core/xray
  ```
  После этого `python3 app.py` запустит xray без предупреждения.

**В: Порт 2080 уже занят, как сменить?**  
Измените `"port": 2080` в `client_config.json` на любой свободный (например, 1080, 9050).

**В: Нужен ли свой сервер?**  
Да, нужен VPS с настроенным Xray-сервером (VLESS + Reality). Это серверная часть, proxy_manager_socks5_xray — только клиент.

**В: Как обновить Xray-core?**  
Скачайте новый бинарник с [releases](https://github.com/XTLS/Xray-core/releases) и замените файл в папке `xray-core/`.

## Версии компонентов

| Компонент | Версия |
|-----------|--------|
| proxy_manager_socks5_xray | 0.1.3 |
| Xray-core | 26.2.6 |

## Примечания

- В Xray 26+ поле публичного ключа Reality называется `password` (не `publicKey`)
- Для отладки измените `"loglevel"` в конфиге на `"debug"`
- Скрипт не требует прав администратора / root
- Каждая платформенная папка полностью автономна

## Сторонняя лицензия

Бинарник **Xray-core** в каждой папке `xray-core/` распространяется под **Mozilla Public License 2.0 (MPL 2.0)**. Полный текст лицензии — в файле `xray-core/LICENSE-Xray.txt`. Исходный код: [XTLS/Xray-core](https://github.com/XTLS/Xray-core).

## Лицензия

[MIT](LICENSE)
