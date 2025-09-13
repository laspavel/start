#!/bin/bash

# Configure vim editor (Linux + macOS)
set -euo pipefail

# Определяем, есть ли wget или curl
download() {
    if command -v curl >/dev/null 2>&1; then
        curl -fLo "$1" "$2"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$1" "$2"
    else
        echo "Error: need curl or wget installed" >&2
        exit 1
    fi
}

# Директории
mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/plugged"

# Загружаем .vimrc
download "$HOME/.vimrc" "https://raw.githubusercontent.com/laspavel/dotfiles/refs/heads/master/.vimrc"

# Загружаем vim-plug
download "$HOME/.vim/autoload/plug.vim" "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

# Удаляем плагины (для чистой установки)
rm -rf "$HOME/.vim/plugged"

# Устанавливаем плагины
vim +'PlugInstall --sync' +qall </dev/tty &>/dev/null || true

echo "SUCCESS !!!"
exit 0
