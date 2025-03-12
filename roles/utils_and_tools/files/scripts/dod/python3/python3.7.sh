#!/bin/bash

yum install -y gcc openssl-devel bzip2-devel libffi-devel
cd /opt && wget https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz
tar xvzf Python-3.7.9.tgz
cd Python-3.7.9
./configure --enable-optimizations
make altinstall
