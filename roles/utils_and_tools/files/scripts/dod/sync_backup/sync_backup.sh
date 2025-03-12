#!/bin/bash

/usr/bin/rsync -avztr --delete --copy-unsafe-links /home/laspavel/_ opc@sg:/home/opc/mnt/bv1/_ 2>&1
# /usr/bin/rsync -avztr -e 'ssh -i /root/.ssh/laspavel-root' --delete --copy-unsafe-links --exclude-from /etc/tools/exclude_pattern root@b:/home /home/laspavel/sdb1/BASTION > /tmp/rsync.log 2>&1
