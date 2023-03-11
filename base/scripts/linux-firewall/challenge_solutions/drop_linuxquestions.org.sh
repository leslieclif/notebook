iptables -A OUTPUT -p tcp --dport 80 -d www.linuxquestions.org -j DROP
iptables -A OUTPUT -p tcp --dport 443 -d www.linuxquestions.org -j DROP

