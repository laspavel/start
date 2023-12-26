#!/bin/bash

# Usage on Server (OracleLinux 8; AlmaLinux 8; RockyLinux 8, Fedora Server 39)

yum install -y epel-release
yum install -y python3 python3-pip
yum install -y ansible
ansible-playbook plays/srv_rpm8.yml