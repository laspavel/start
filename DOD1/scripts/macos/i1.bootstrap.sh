#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

HOSTNAME_="${HOSTNAME_:-MacBook}"
TIMEZONE="${TIMEZONE:-Europe/Kyiv}"
WORK_DIR="${WORK_DIR:-$HOME}"
WORK_USER="${WORK_USER:-$USER}"
NTP_SERVER="${NTP_SERVER:-time.apple.com}"

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# =========================
# XCode command line tools
# =========================
# ===== Xcode CLT =====
if ! xcode-select -p >/dev/null 2>&1; then
  sudo xcode-select --install || true
  echo "Waiting for Xcode Command Line Tools..."
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

# ==================
# Rozetta2
# ==================
if [[ "$(uname -m)" == "arm64" ]]; then
  sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
fi

# =====================
# Brew
# =====================
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then BREW_PREFIX=/opt/homebrew; else BREW_PREFIX=/usr/local; fi
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  sudo tee -a /etc/zshenv >/dev/null <<EOF
eval "\$($BREW_PREFIX/bin/brew shellenv)"
EOF
else
  if [[ -x /opt/homebrew/bin/brew ]]; then BREW_PREFIX=/opt/homebrew; else BREW_PREFIX=/usr/local; fi
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
fi
brew update
brew upgrade

# =====================
# git
# =====================
brew install git

# ==================
# BASH
# ==================
brew install bash
echo "$(which bash)" | sudo tee -a /etc/shells
sudo chsh -s "$(which bash)" "$WORK_USER"

# ======================
#  Fonts
# ======================
# brew tap homebrew/cask-fonts
# brew install font-droid-sans-mono font-droid-sans-mono-nerd-font

# =====================
# cli tools
# =====================
brew install \
  coreutils findutils diffutils gnu-indent gnu-sed ed gnu-tar gnutls grep gnu-which \
  gawk gzip watch less nano make mc htop vim tig curl wget jq bash-completion unzip ncdu bind \
  ffmpeg mpv mtr nginx openssl@3 tmux rsync

# GitHub - imsnif/bandwhich: Terminal bandwidth utilization tool https://github.com/imsnif/bandwhich
brew install bandwhich

# Nmap: the Network Mapper - Free Security Scanner https://nmap.org/
brew install nmap

# GitHub - sivel/speedtest-cli: Command line interface for testing internet bandwidth using speedtest.net https://github.com/sivel/speedtest-cli
brew install speedtest-cli

# ===== locate DB =====
sudo /usr/libexec/locate.updatedb || true

# =====================
#  Python
# =====================
brew install python pipx
brew install pyenv
eval "$(pyenv init -)"
pyenv install -s 3.11.13
pyenv global 3.11.13
# pyenv global system

# =====================
# Docker & Colima
# =====================
if brew list docker-compose &>/dev/null; then
    brew uninstall docker-compose
fi
brew install docker docker-compose colima docker-buildx
colima stop || true
colima delete -f || true
colima start --vm-type=vz --vz-rosetta --cpu 4 --memory 6 --disk 60 || true

mkdir -p "$HOME/.docker"
if [[ -f "$HOME/.docker/config.json" ]]; then
  # аккуратно добавим ключ, если его нет
  if ! grep -q '"cliPluginsExtraDirs"' "$HOME/.docker/config.json"; then
    /usr/bin/plutil -replace cliPluginsExtraDirs -json '["/opt/homebrew/lib/docker/cli-plugins"]' "$HOME/.docker/config.json" 2>/dev/null \
      || jq '. + {cliPluginsExtraDirs: ["/opt/homebrew/lib/docker/cli-plugins"]}' "$HOME/.docker/config.json" > "$HOME/.docker/config.json.tmp" && mv "$HOME/.docker/config.json.tmp" "$HOME/.docker/config.json"
  fi
else
  cat > "$HOME/.docker/config.json" <<'JSON'
{
  "cliPluginsExtraDirs": ["/opt/homebrew/lib/docker/cli-plugins"]
}
JSON
fi

ls -l /opt/homebrew/lib/docker/cli-plugins/ || true
docker --version || true
docker compose version || true
docker buildx version || true

# ======================
#  Timezone
# ======================
sudo systemsetup -settimezone "$TIMEZONE"

# ======================
#  Hostname
# ======================
sudo scutil --set HostName "$HOSTNAME_"
sudo scutil --set ComputerName "$HOSTNAME_"
SANITIZED="$(echo "$HOSTNAME_" | tr -cd '[:alnum:]-' | tr '[:upper:]' '[:lower:]' )"
sudo scutil --set LocalHostName "$SANITIZED"
dscacheutil -flushcache

# =====================
# AutoComplete
# =====================
if [[ ! -d "$WORK_DIR/.local/.bash.autocomplete.d" ]]; then
  mkdir -p "$WORK_DIR/.local/.bash.autocomplete.d"
  sudo chown -R "$WORK_USER":"$(id -gn "$WORK_USER")" "$WORK_DIR/.local/.bash.autocomplete.d" || true
  chmod 0755 "$WORK_DIR/.local/.bash.autocomplete.d"
fi

curl -fsSL -z "$WORK_DIR/.local/.bash.autocomplete.d/git-completion.bash" -o "$WORK_DIR/.local/.bash.autocomplete.d/git-completion.bash" "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" || {
  curl -fsSL -o "$WORK_DIR/.local/.bash.autocomplete.d/git-completion.bash" "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
}
chmod 0664 "$WORK_DIR/.local/.bash.autocomplete.d/git-completion.bash"
sudo chown "$WORK_USER":"$(id -gn "$WORK_USER")" "$WORK_DIR/.local/.bash.autocomplete.d/git-completion.bash" || true

# =====================
# SSH On
# =====================
sudo systemsetup -setremotelogin on
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist || true

# =====================
# NTP Setup
# =====================
sudo systemsetup -setnetworktimeserver "$NTP_SERVER"
sudo systemsetup -setusingnetworktime on
if command -v sntp &>/dev/null; then
  sudo sntp -sS "$NTP_SERVER" || true
fi

# =====================
# Restore dotfiles from repo
# =====================
TMP_DOTFILES="$(mktemp -d /tmp/dotfiles.XXXXXX)" || exit 1
git clone --depth=1 "https://github.com/laspavel/dotfiles.git" "$TMP_DOTFILES"
sudo chown -R "$WORK_USER":"$(id -gn "$WORK_USER")" "$TMP_DOTFILES" || true
chmod +x "$TMP_DOTFILES/bootstrap.sh"
sudo -u "$WORK_USER" env HOME="$WORK_DIR" bash -lc "cd '$TMP_DOTFILES' && ./bootstrap.sh --restore"
rm -rf "$TMP_DOTFILES" || true

# =====================
# K8S
# =====================
brew install kubernetes-cli

# Krew – kubectl plugin manager - (https://krew.sigs.k8s.io/)
#(
#  set -x; cd "$(mktemp -d)" &&
#  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
#  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
#  KREW="krew-${OS}_${ARCH}" &&
#  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
#  tar zxvf "${KREW}.tar.gz" &&
#  ./"${KREW}" install krew
#)
#kubectl krew update
#kubectl krew install ctx explore fuzzy ice krew ktop lineage ns resource-capacity status stern view-allocations view-secret whoami

# [kubefwd - Kubernetes Service Forwarding](https://kubefwd.com/)
# brew install txn2/tap/kubefwd

# =====================
# Casks
# =====================
brew install --cask visual-studio-code google-chrome obs meld qbittorrent double-commander vlc
brew install --cask karabiner-elements
brew install --cask key-codes

# =====================
# Configuration
# =====================

# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable "natural" scroll
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Finder: show hidden files by default
#defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show icons for hard drives, servers, and removable media on the desktop
#defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
#defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
#defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
#defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Don't create .DS_Store on Network and USB Devices
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Smart quotes/dashes off (удобнее для кода)
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled  -bool false

# Full Keyboard Access (Tab по всем контролам)
defaults write -g AppleKeyboardUIMode -int 3

# Scrollbars always visible
defaults write -g AppleShowScrollBars -string "Always"

# Disable focus ring animation
defaults write -g NSUseAnimatedFocusRing -bool false

# Remove toolbar title hover delay (proxy icon)
defaults write -g NSToolbarTitleViewRolloverDelay -float 0

# Terminal UTF-8
defaults write com.apple.terminal StringEncodings -array 4

# Отключить стандартное сочетание для Spotlight
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "{enabled = 0; }"

# Установить переключение раскладки на Cmd+Space
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "{enabled = 1; value = {parameters = (32, 49, 1048576); type = standard; }; }"

# Safari privacy toggles (могут игнорироваться в новых версиях)
defaults write com.apple.Safari UniversalSearchEnabled    -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Dock speedups
defaults write com.apple.dock autohide-delay         -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4

# Finder: no warning on emptying Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Перезапуски (один раз на блок)
killall Dock    >/dev/null 2>&1 || true
killall Finder  >/dev/null 2>&1 || true

echo "SUCCESS !!!"
exit 0
