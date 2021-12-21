#!/bin/bash

sudo dnf -y update
sudo dnf -y upgrade --refresh
sudo dnf -y install dnf-plugin-system-upgrade --best
sudo dnf -y system-upgrade download --releasever=35
sudo dnf system-upgrade reboot

### After reboot ###
sudo rpm --rebuilddb
sudo dnf distro-sync --setopt=deltarpm=0
sudo dnf install rpmconf
sudo rpmconf -a
