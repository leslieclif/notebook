#!/bin/bash

iptables -t filter -A FORWARD -p udp --dport 53 -o eth0 -d 208.67.222.123 -j ACCEPT
iptables -t filter -A FORWARD -p udp --dport 53 -o eth0 -j DROP

