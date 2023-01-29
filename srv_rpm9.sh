#!/bin/bash

# Usage on Server (OracleLinux 9; AlmaLinux 9; RockyLinux 9)

yum install -y epel-release
yum install -y ansible-core
ansible-galaxy collection install -r plays/requirements.yml -p ./collections
ansible-playbook plays/srv_rpm9.yml