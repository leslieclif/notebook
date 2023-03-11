#!/bin/bash

iptables -F

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


iptables -P INPUT DROP
iptables -P OUTPUT DROP
