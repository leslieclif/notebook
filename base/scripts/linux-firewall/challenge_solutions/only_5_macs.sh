#!/bin/bash

## allowed MAC addreses
MAC="b4:6d:83:77:85:f1 b4:6d:83:77:85:f2 b4:6d:83:77:85:f3 b4:6d:83:77:85:f4 b4:6d:83:77:85:f5"

for M in $MAC
do
	iptables -A INPUT -m mac --mac-source $M -j ACCEPT
done

# setting the drop policy
iptables -P INPUT DROP

