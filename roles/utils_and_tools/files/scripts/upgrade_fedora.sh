#!/bin/bash

sudo dnf -y update
sudo dnf -y upgrade --refresh
sudo dnf -y install dnf-plugin-system-upgrade --best
sudo dnf -y system-upgrade download --releasever=39
sudo dnf system-upgrade reboot

### After reboot ###
sudo rpm --rebuilddb
sudo dnf distro-sync --setopt=deltarpm=0
sudo dnf install rpmconf
sudo rpmconf -a

gnome-shell-extension-installer 1160 --yes --restart-shell
