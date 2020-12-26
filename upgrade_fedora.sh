#!/bin/bash

sudo dnf -y update
sudo dnf -y upgrade --refresh
sudo dnf -y install dnf-plugin-system-upgrade
sudo dnf -y system-upgrade download --releasever=33
sudo dnf system-upgrade reboot
