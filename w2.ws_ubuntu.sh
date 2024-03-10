#!/bin/bash

# Usage on Workstation (Ubuntu 22.04 LTS)

apt install -y python3 python3-pip
apt install -y ansible
ansible-playbook plays/ws_ubuntu.yml