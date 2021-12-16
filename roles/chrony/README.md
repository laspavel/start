# Ansible role for Chrony installation

## Introduction

[Chrony](https://chrony.tuxfamily.org/) is a NTP client implementation,
running as a daemon.

This role installs and configure the server. The server is configured to serve the local machine only.

## Variables

- **servers**: list of servers to synchronize with
- **servers_preferred**: optional additional servers to synchronize with; these ones would be preferred over the `servers` list if they work well

