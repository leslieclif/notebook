iptables -A FORWARD -p tcp --dport 22 --syn -i eth0 -j ACCEPT
iptables -A FORWARD -p tcp --dport 22 --syn -i eth1 -j DROP
