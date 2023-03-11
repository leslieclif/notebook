#!/bin/bash

# flushing the filter table of all chains
iptables -F

# allowing loopback interface traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT


# dropping invalid packets
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP


# allowing incoming ssh connections from 100.0.0.1
iptables -A INPUT -p tcp --dport 22 --syn -s 100.0.0.1 -j ACCEPT

# allow only the return traffic on the INPUT chain
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


# setting the default policy to drop
iptables -P INPUT DROP
iptables -P OUTPUT DROP
