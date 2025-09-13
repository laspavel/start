#!/bin/bash

set -euo pipefail

echo "🧼 Удаление старой версии docker-compose (v1)..."
if brew list docker-compose &>/dev/null; then
    brew uninstall docker-compose
    echo "✅ Удалено."
else
    echo "ℹ️ docker-compose v1 не установлен через Homebrew."
fi

echo "📦 Установка docker CLI и плагинов (compose, buildx)..."
brew install docker docker-compose docker-buildx

echo "🔍 Проверка версий..."
docker --version
docker compose version
docker buildx version

echo "🧪 Проверка зарегистрированных плагинов..."
docker --help | grep compose || echo "❌ compose плагин не зарегистрирован!"
docker --help | grep buildx || echo "❌ buildx плагин не зарегистрирован!"

# Предлагаем добавить алиас
read -p "🔁 Добавить alias docker-compose='docker compose' в ~/.zshrc или ~/.bashrc? (y/n): " reply
if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
    SHELL_RC="$HOME/.zshrc"
    [ -n "$BASH_VERSION" ] && SHELL_RC="$HOME/.bashrc"
    if ! grep -q "alias docker-compose=" "$SHELL_RC"; then
        echo "alias docker-compose='docker compose'" >> "$SHELL_RC"
        echo "✅ Alias добавлен в $SHELL_RC"
    else
        echo "ℹ️ Alias уже существует в $SHELL_RC"
    fi
fi

echo "🎉 Установка завершена."
