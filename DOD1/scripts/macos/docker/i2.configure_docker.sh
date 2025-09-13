#!/bin/bash
set -euo pipefail

ENABLE_PROXY=0
if [[ "${1:-}" == "--enable-proxy" ]]; then
  ENABLE_PROXY=1
fi

log() { printf "%s %s\n" "$(date '+%F %T')" "$*"; }
need_root() { [[ $EUID -eq 0 ]] || { echo "Требуются root-права: sudo $0"; exit 1; }; }
have() { command -v "$1" >/dev/null 2>&1; }

need_root

# --- 1) Docker CLI + плагины ---
log "🧼 Удаление старого docker-compose (v1), если был установлен через brew..."
if brew list docker-compose &>/dev/null; then
  brew uninstall docker-compose
  log "✅ Удалено."
else
  log "ℹ️ docker-compose v1 не установлен через Homebrew."
fi

log "📦 Установка docker CLI и плагинов (compose, buildx)..."
brew install docker docker-compose docker-buildx

log "🔍 Проверка версий..."
docker --version || true
docker compose version || true
docker buildx version || true

log "🧪 Проверка зарегистрированных плагинов..."
docker --help | grep -q ' compose ' || echo "❌ compose плагин не зарегистрирован!"
docker --help | grep -q ' buildx '  || echo "❌ buildx плагин не зарегистрирован!"

# Предложить alias
read -p "🔁 Добавить alias docker-compose='docker compose' в ~/.zshrc или ~/.bashrc? (y/n): " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
  SHELL_RC="$HOME/.zshrc"
  [[ -n "${BASH_VERSION:-}" ]] && SHELL_RC="$HOME/.bashrc"
  if ! grep -q "alias docker-compose=" "$SHELL_RC" 2>/dev/null; then
    echo "alias docker-compose='docker compose'" >> "$SHELL_RC"
    log "✅ Alias добавлен в $SHELL_RC"
  else
    log "ℹ️ Alias уже существует в $SHELL_RC"
  fi
fi

# --- 2) Периодические задачи через launchd (замена /etc/cron.d для macOS) ---
# Задача 1: docker system prune -a --filter "until=2h"
PRUNE_PLIST="/Library/LaunchDaemons/com.local.docker.prune.plist"
cat > "$PRUNE_PLIST" <<'PL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.local.docker.prune</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-lc</string>
    <string>docker system prune -f --filter "until=2h" -a &gt;/dev/null 2&gt;&amp;1</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>1</integer>
    <key>Minute</key><integer>0</integer>
  </dict>
  <key>RunAtLoad</key><false/>
  <key>StandardOutPath</key><string>/dev/null</string>
  <key>StandardErrorPath</key><string>/dev/null</string>
</dict>
</plist>
PL

# Задача 2: удалить dangling volumes
VOL_PLIST="/Library/LaunchDaemons/com.local.docker.volumes-cleanup.plist"
cat > "$VOL_PLIST" <<'PL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.local.docker.volumes-cleanup</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-lc</string>
    <string>for vol in $(docker volume ls -q -f dangling=true); do docker volume rm "$vol" &gt;/dev/null 2&gt;&amp;1 || true; done</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>1</integer>
    <key>Minute</key><integer>1</integer>
  </dict>
  <key>RunAtLoad</key><false/>
  <key>StandardOutPath</key><string>/dev/null</string>
  <key>StandardErrorPath</key><string>/dev/null</string>
</dict>
</plist>
PL

chown root:wheel "$PRUNE_PLIST" "$VOL_PLIST"
chmod 0644 "$PRUNE_PLIST" "$VOL_PLIST"

# Перезагрузить задания
launchctl unload "$PRUNE_PLIST" 2>/dev/null || true
launchctl unload "$VOL_PLIST" 2>/dev/null || true
launchctl load -w "$PRUNE_PLIST"
launchctl load -w "$VOL_PLIST"

# Проверка синтаксиса
# plutil -lint /Library/LaunchDaemons/com.local.docker.prune.plist

log "✅ Периодические задачи установлены (1:00 и 1:01 ежедневно через launchd)."

# --- 3) daemon.json ---
DAEMON_JSON_CONTENT='{
 "log-driver": "json-file",
 "log-opts": {
    "max-size": "20m",
    "max-file": "3"
  },
 "default-address-pools": [
   {"base":"10.250.250.0/16","size":24}
 ]
}'

# Определяем окружение: Colima vs Docker Desktop
IS_COLIMA=0
if have colima && colima status >/dev/null 2>&1; then
  IS_COLIMA=1
fi

if [[ $IS_COLIMA -eq 1 ]]; then
  COLIMA_PROFILE="${COLIMA_PROFILE:-default}"
  COLIMA_DIR="$HOME/.colima/${COLIMA_PROFILE}"
  mkdir -p "$COLIMA_DIR"
  DAEMON_JSON_PATH="$COLIMA_DIR/daemon.json"

  # Бэкап
  if [[ -f "$DAEMON_JSON_PATH" ]]; then
    cp -a "$DAEMON_JSON_PATH" "${DAEMON_JSON_PATH}.$(date +%Y%m%d%H%M%S).bak"
  fi
  printf "%s\n" "$DAEMON_JSON_CONTENT" > "$DAEMON_JSON_PATH"
  log "✅ Записан $DAEMON_JSON_PATH"

  # Перезапуск Colima, чтобы применить настройки dockerd
  log "🔄 Перезапуск Colima (${COLIMA_PROFILE}) для применения daemon.json..."
  colima stop "${COLIMA_PROFILE}" || true
  # Если профиль ещё не создан — стартуем с docker и укажем, что нужен dockerd
  colima start "${COLIMA_PROFILE}" --docker
  log "✅ Colima перезапущен."
else
  # Docker Desktop?
  if [[ -d "/Applications/Docker.app" ]]; then
    log "⚠️ Обнаружен Docker Desktop. Он НЕ читает host:/etc/docker/daemon.json; используйте настройки в GUI (Resources → Advanced, etc.) или переключитесь на Colima."
  else
    # Нейтральный путь для Linux, но на macOS dockerd на хосте обычно не работает:
    mkdir -p /etc/docker
    echo "$DAEMON_JSON_CONTENT" > /etc/docker/daemon.json
    log "ℹ️ /etc/docker/daemon.json создан, но на macOS dockerd на хосте обычно не используется. Рассмотрите Colima."
  fi
fi

# --- 4) (Опционально) Proxy для dockerd внутри Colima VM ---
if [[ $ENABLE_PROXY -eq 1 ]]; then
  if [[ $IS_COLIMA -eq 0 ]]; then
    log "⚠️ --enable-proxy задан, но Colima не обнаружен. Пропускаю настройку прокси."
  else
    HTTP_PROXY_VAL="${HTTP_PROXY:-}"
    HTTPS_PROXY_VAL="${HTTPS_PROXY:-${HTTP_PROXY_VAL}}"
    NO_PROXY_VAL="${NO_PROXY:-localhost,127.0.0.1,::1}"

    if [[ -z "$HTTP_PROXY_VAL" && -z "$HTTPS_PROXY_VAL" ]]; then
      log "⚠️ Для включения прокси задайте переменные HTTP_PROXY/HTTPS_PROXY и повторите запуск с --enable-proxy."
    else
      log "🔧 Настройка прокси для dockerd внутри Colima-VM (systemd drop-in)..."
      colima ssh "${COLIMA_PROFILE}" sudo mkdir -p /etc/systemd/system/docker.service.d
      colima ssh "${COLIMA_PROFILE}" "printf '%s\n' \
\"[Service]\" \
\"Environment=HTTP_PROXY=${HTTP_PROXY_VAL}\" \
\"Environment=HTTPS_PROXY=${HTTPS_PROXY_VAL}\" \
\"Environment=NO_PROXY=${NO_PROXY_VAL}\" \
| sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf >/dev/null"

      log "🔄 Перезапуск docker.service в Colima-VM..."
      colima ssh "${COLIMA_PROFILE}" sudo systemctl daemon-reload
      colima ssh "${COLIMA_PROFILE}" sudo systemctl restart docker.service
      log "✅ Прокси применён."
    fi
  fi
fi

log "🎉 Готово."
