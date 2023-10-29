#!/bin/bash

# IPv4 HTTP Flood Block

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p icmp -m icmp --icmp-type 8 -m conntrack --ctstate NEW,RELATED,ESTABLISHED -m hashlimit --hashlimit-above 15/sec --hashlimit-burst 5 --hashlimit-mode srcip --hashlimit-name PING --hashlimit-htable-expire 300000 -j DROP

# IPv6 HTTP Flood Block
firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -p icmpv6 -m icmpv6 --icmpv6-type 8 -m conntrack --ctstate NEW,RELATED,ESTABLISHED -m hashlimit --hashlimit-above 15/sec --hashlimit-burst 5 --hashlimit-mode srcip --hashlimit-name PING --hashlimit-htable-expire 300000 -j DROP

firewall-cmd --reload
firewall-cmd --get-all-rules --direct

# https://www.golinuxcloud.com/prevent-icmp-ping-flood-attack-linux/
