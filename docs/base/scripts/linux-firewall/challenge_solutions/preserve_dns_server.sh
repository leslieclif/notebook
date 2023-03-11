iptables -A FORWARD -p udp --dport 53 ! -d 8.8.8.8 -j DROP
