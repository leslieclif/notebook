iptables -A INPUT -p tcp --dport 22 --syn -m limit --limit 1/sec -j LOG --log-prefix="ssh in:"

iptables -A INPUT -p tcp --dport 22 -j REJECT

# displaying logs:
dmesg

# filtering logs by prefix
dmesg | grep "ssh in:" 
