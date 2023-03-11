iptables -I INPUT -s 100.0.0.1 -j DROP
iptables -I INPUT -s 1.2.3.4 -j DROP

iptables -I OUTPUT -d 80.0.0.1 -j DROP
