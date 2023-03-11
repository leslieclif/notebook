iptables -A INPUT -p tcp --dport 22 --syn -j LOG --log-prefix="ssh in:"
iptables -A INPUT -p tcp --dport 22 -j REJECT

