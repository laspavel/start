# Start #

Playbooks for prepare my workstation and Bastion (GoldenGate) servers.

**Requirements:**
* python3 and python3-pip
* Ansible
* root user on target PC
* if required restore all personal configs add password to ~/.pass

**Usage on Workstation (Fedora Workstation 36-37):**
```
dnf install python3 python3-pip
dnf install -y ansible
ansible-playbook ws_fedora.yml
```

**Usage on Server (OracleLinux 8; AlmaLinux 8; RockyLinux 8, Fedora Server 36-37):**
```
yum install -y epel-release
yum install -y python3 python3-pip
yum install -y ansible
ansible-playbook srv_rpm8.yml
```

**Usage on Server (Debian 11):**

```
apt install -y python3 python3-pip
apt install -y ansible
ansible-playbook srv_deb.yml
```

## License ##

MIT / BSD

## Author Information ##

This playbook was created in 2021-2023 by [Pavel Lashkevych](https://laspavel.top/).
