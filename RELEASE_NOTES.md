## proxy_manager_socks5_xray v0.1.2

### English

Local SOCKS5 proxy manager powered by Xray-core (VLESS + Reality). Use with any SOCKS5-capable app; originally made for Telegram.

**Download**

| File | Platform | Architecture |
|------|----------|--------------|
| `proxy_manager_socks5_xray_mac_arm64.zip` | macOS | ARM64 (Apple Silicon) |
| `proxy_manager_socks5_xray_linux_amd64.zip` | Linux | x86-64 (amd64) |
| `proxy_manager_socks5_xray_win_amd64.zip` | Windows | x86-64 (amd64) |

**Quick start**

1. Download the archive for your OS
2. Extract it
3. Edit `client_config.json` — add your server details (or use `--vless "vless://..."`)
4. Run: `python3 teleproxy.py` (macOS/Linux) or `python teleproxy.py` (Windows)
5. Point any app to SOCKS5 `127.0.0.1:2080`. For Telegram: Settings → Proxy → SOCKS5 → same address.

**Components**

- proxy_manager_socks5_xray 0.1.2
- Xray-core 26.2.6
- Python 3.7+

---

### Русский

Локальный SOCKS5 прокси-менеджер на базе Xray-core (VLESS + Reality). Подходит для любого приложения с поддержкой SOCKS5; изначально делался под Telegram.

**Скачивание**

| Файл | Платформа | Архитектура |
|------|-----------|-------------|
| `proxy_manager_socks5_xray_mac_arm64.zip` | macOS | ARM64 (Apple Silicon) |
| `proxy_manager_socks5_xray_linux_amd64.zip` | Linux | x86-64 (amd64) |
| `proxy_manager_socks5_xray_win_amd64.zip` | Windows | x86-64 (amd64) |

**Быстрый старт**

1. Скачайте архив для вашей ОС
2. Распакуйте
3. Отредактируйте `client_config.json` — подставьте данные вашего сервера (или используйте `--vless "vless://..."`)
4. Запустите: `python3 teleproxy.py` (macOS/Linux) или `python teleproxy.py` (Windows)
5. Укажите в любом приложении SOCKS5 `127.0.0.1:2080`. Для Telegram: Настройки → Прокси → SOCKS5 → тот же адрес.

**Компоненты**

- proxy_manager_socks5_xray 0.1.2
- Xray-core 26.2.6
- Python 3.7+
