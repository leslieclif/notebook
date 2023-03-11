iptables -A FORWARD -p tcp --dport 80 -d www.linuxquestions.org -j DROP
iptables -A FORWARD -p tcp --dport 443 -d www.linuxquestions.org -j DROP

