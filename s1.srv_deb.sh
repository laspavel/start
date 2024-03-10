#!/bin/bash

# Usage on Server (Debian 11)

apt update
apt install -y python3 python3-pip
apt install -y ansible
ansible-playbook plays/srv_deb.yml