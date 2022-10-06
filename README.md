# Playbooks for start work and GoldenGate (Bastion) servers.

Ansible roles for my start.

**Requirements:**
* Ansible
* Git
* if required restore all gnome configs add password to ~/.pass

**Usage Fedora (from root):**
```
dnf install -y ansible git
ansible-playbook start_Fedora.yml
```

**Usage CentOS7 (from root):**
```
yum install epel-release && yum install -y ansible git
ansible-playbook start_CentOS7.yml
```

**Usage Oracle Linux 8 (from root):**
```
yum install oracle-epel-release-el8 && yum install -y ansible git
ansible-playbook start_OL8.yml
```
