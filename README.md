# Start – Automated Workstation & Server Initialization

Start is a collection of Ansible-based shell wrappers designed to quickly configure Fedora/Ubuntu workstations and Bastion (GoldenGate) servers running Debian, Oracle Linux, AlmaLinux, Rocky Linux, or Fedora Server.

## 📌 Features

* Unified setup for workstations and servers using Ansible roles
* OS-aware scripts for different Linux distributions
* Custom roles for security hardening, package installation, and more
* Fast and repeatable provisioning for personal and enterprise systems

## ⚙️ Requirements

* Python 3 and python3-pip
* Ansible installed on the control node
* Root access to the target machine

## 🚀 Quick Start

### 🖥️ For Workstations

* Fedora Workstation 41
```bash
bash w1.ws_fedora.sh
```

* Ubuntu 22.04 LTS
```bash
bash w2.ws_ubuntu.sh
```

### 🖥️ For Servers

* Debian 11

```bash
bash s1.srv_deb.sh
```

* Oracle Linux 8 / AlmaLinux 8 / Rocky Linux 8 / Fedora Server 38
```bash
bash s2.srv_rpm8.sh
```

* Oracle Linux 9 / AlmaLinux 9 / Rocky Linux 9

```bash
bash s3.srv_rpm9.sh
```

## 📁 Repository Structure
```plaintext
start/
├── plays/               # Ansible playbooks
├── roles/               # Custom roles
├── vars/                # Group and host variable definitions
├── scripts/             # Auxiliary scripts
├── *.sh                 # Launcher scripts per OS
├── ansible.cfg          # Configuration file for Ansible
└── README.md            # Project documentation
```

## 🛡️ License

MIT License.

## 🤝 Contributions

Suggestions and improvements are welcome! Feel free to open an issue or submit a pull request.

## 📬 Contact

Author: [laspavel](https://github.com/laspavel)

Feel free to reach out with questions or ideas.

---
