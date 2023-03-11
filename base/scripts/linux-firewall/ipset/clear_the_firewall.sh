#!/bin/bash

# This script completely flushes ipset and iptables rules and reset to an open firewall state.

echo "Setting ACCEPT policy on all iptables chains."
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

echo "Flushing all iptables tables."
iptables -t filter -F
iptables -t raw -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

echo "Flushing and destroying all ip sets."
ipset -F
ipset -X
