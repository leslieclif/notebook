#!/bin/bash

iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m time --timestart 10:00 --timestop 18:00 -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j DROP

