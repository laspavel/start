# Playbooks for start work and GoldenGate (Bastion) servers.

Ansible roles for my start.

**Requirements:**
* python3 python3-pip
* Ansible
* Git
* if required restore all gnome configs add password to ~/.pass

**Usage Fedora (from root):**
```
dnf install python3 python3-pip
dnf install -y ansible git
ansible-playbook ws_fedora_user.yml
```

**Usage Oracle Linux 8 (from root):**
```
yum install -y epel-release && yum install -y python3 python3-pip && yum install -y ansible git
ansible-playbook srv_rpm8_root.yml
```

