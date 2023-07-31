#!/bin/bash

IP_MASK_LAN=$1

# enable routing
echo 1 > /proc/sys/net/ipv4/ip_forward

# free firewall
iptables --flush
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# set nat
iptables -t nat --flush
iptables -t nat -I POSTROUTING -s $IP_MASK_LAN -o eth2 -j MASQUERADE