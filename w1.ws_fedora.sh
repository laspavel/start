#!/bin/bash

# Usage on Workstation (Fedora Workstation 36-37)

dnf install -y python3 python3-pip
dnf install -y ansible
pip3 install passlib
ansible-playbook plays/ws_fedora.yml