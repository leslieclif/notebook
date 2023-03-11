iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 2/sec -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

