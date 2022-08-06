[netstat](https://www.binarytides.com/linux-netstat-command-examples/)
[nmap](https://www.cyberciti.biz/security/nmap-command-examples-tutorials/)
# Linux Firewall Fundamentals
- Firewalls control network access.
- Linux firewall = Netfilter + IPTables
- Netfilter is a kernel framework.
- IPTables is a packet selection system.
- Use the `iptables` command to control the firewall.
## Default Tables
- Filter - Most commonly used table.
- NAT - Network Address Translation.
- Mangle - Alter packets.
- Raw - Used to disable connection tracking.
- Security - Used by SELinux.
## Default Chains
- INPUT
- OUTPUT
- FORWARD
- PREROUTING
- POSTROUTING
## Rules
- Rules = Match + Target
- Match on: Protocol, Source/Dest IP or network, Source/Dest Port, Network Interface
- Example: `protocol: TCP, source IP: 1.2.3.4, dest port: 80`
## Targets
- Built-in targets:
- ACCEPT
- DROP
- REJECT
- LOG
- RETURN
## iptables / ip6tables
- Command line interface to IPTables/netfilter.
## List / View iptables
```BASH
iptables -L                     # Display the filter table.
iptables -t nat -L              # Display the nat table.
iptables -nL                    # Display using numeric output.
iptables -vL                    # Display using verbose output.
iptables --line-numbers -L      # Use line nums.
```
## Chain Policy / Default Target
- Set the default TARGET for CHAIN: `iptables -P CHAIN TARGET`
- Example: `iptables -P INPUT DROP`
```BASH
# Appending Rules
iptables -A CHAIN RULE-SPECIFICATION
iptables [-t TABLE] -A CHAIN RULE-SPECIFICATION
# Inserting Rules
iptables -I CHAIN [RULENUM] RULE-SPECIFICATION
# Deleting Rules
iptables -D CHAIN RULE-SPECIFICATION
iptables -D CHAIN RULENUM
# Flushing rules or deleting tables
iptables [-t table] -F [chain]
```
## Rule Specification Options
```BASH
-s 10.11.12.13                          # Source IP, network, or name
-d 216.58.192.0/19                      # Destination IP, network, or name
-p tcp / udp / icmp                     # Protocol
-p tcp --dport 80                       # Destination Port
-p tcp --sport 8080                     # Source Port
-p icmp --icmp-type echo-reply          # ICMP packet type, gives pong response
-p icmp --icmp-type echo-request        # Gives ping response
# Rating limiting
-m limit --limit rate[/second/minute/hour/day] # Match until a limit is reached.
-m limit --limit-burst                  # --limit default is 3/hour and --limit-burst default is 5
-m limit --limit 5/m --limit-burst 10   # /s = second, /m = minutes
-m limit ! --limit 5/s                  # ! = invert the match
```
## Target / Jump
- To specify a jump point or target: `-j TARGET_OR_CHAIN`
```BASH
-j ACCEPT               # Built-in target.
-j DROP                 # Built-in target.
-j LOGNDROP             # Custom chain.
```
## Creating and Deleting a Chain
- Create CHAIN: iptables [-t table] -N CHAIN
- Delete CHAIN: iptables [-t table] -X CHAIN
## Saving Rules
```BASH
# Debian / Ubuntu:
apt-get install iptables-persistent
netfilter-persistent save
```
- [Chain Traversal Flowchart](https://stuffphilwrites.com/2014/09/iptables-processing-flowchart/)
## Netfilter/iptable Front-Ends
- Uses iptables command on the back-end
- Firewalld - CentOS/RHEL
- UFW - Uncomplicated FireWall (Ubuntu)
- GUFW - Graphical interface to UFW
- system-configure-firewall - CentOS/RHEL
## IP Tables Examples
```BASH
# Allow anyone to connect to webserver, but only internal ips to connect via SSH
# Block all other traffic
iptables -L                             # List the existing rules, no rules
# Accept all incoming TCP traffic on port 80
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
# OR
iptables -A INPUT -s 0/0 -p tcp --dport 80 -j ACCEPT
iptables -nL                            # List the current new rule
# Accept all incoming SSH traffic on port 22 originating from the internal network
iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/24 -j ACCEPT
# Drop all packets which dont match above 2 rules
iptables -A INPUT  -j DROP

# Testing the filters
nc -v 10.0.0.8 80                       # Net cat using an internal IP on port 80
nc -v 10.0.0.8 22                       # Test the SSH connection

# Deleting existing rule
iptables -D INPUT 1                     # Deletes the Web server traffic on port 80

nc -w 2 -v 10.0.0.8 80                  # -w specifies timeout of 2 seconds

# Reject the packets instead of dropping them
iptables -D INPUT 2                     # Deletes the drop rule
iptables -A INPUT -J REJECT             # Now rejects the packets
nc -w 2 -v 10.0.0.8 80                  # Connection refused

# Flush all existing rules
iptables -F

iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/24 -j ACCEPT
# Create a new custom table
iptables -N LOGNDROP
# Create a rule to log all incoming traffic other than internal network SSH connection 
iptables -A LOGNDROP -p tcp -m limit --limit 5/min -j LOG --log-prefix "iptables BLOCK "
iptables -A INPUT -j LOGNDROP           # Accept and log before dropping the connection other than internal network

# In another terminal, tail the syslog file
tail -f /var/log/syslog

# Other terminal
nc -w 2 -v 10.0.0.8 80                  # This will log and drop the connection

# Persist the iptables changes after reboot
netfilter- persistent save
```
## Rule Specification Example
```BASH
# To drop all traffic from given source ip
iptables -A INPUT -s 216.58.219.174 -j DROP
# List the filter table, as the above rule didnt specify table name
iptables -nL
# Chain INPUT (policy ACCEPT)
# target prot opt source         destination
# DROP   all  --  216.58.219.174 0.0.0.0/0

# Accept SSH connection from only one network, drop all other SSH connections
iptables -A INPUT -s 10.0.0.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

# Accept incoming HTTPS traffic from source or any destination
iptables -A INPUT -s 8.8.8.8 -p tcp --dport 443 -j ACCEPT  # Accept incoming traffic from google
iptables -A INPUT -s 0/0 -p tcp --dport 443 -j ACCEPT # Incoming traffic from anywhere

# Drop outgoing traffic to ubuntu.com
iptables -A OUTPUT -d www.ubuntu.com -j DROP
iptables -vnL           # List shows ubuntu domain name has been resolved to IP address for ubuntu
iptables -A OUTPUT -p tcp --dport 443 -d www.ubuntu.com -j DROP # Drop only HTTPS traffic
# Use an application Firewall like SQUID to block big websites like google.com or facebook.com 
# instead of using IPTables

# Using IP Ranges to filter traffic
# This range filter helps to keep the IPTables managable and readable
iptables -A INPUT -p tcp --dport 25 -m iprange --src-range 10.0.0.10-10.0.0.19 -j DROP
# This drops SMTP tcp traffic coming from the 10 ip addresses on port 25
# Dropping outgoing traffic destined for type MULTICAST to avoid joining the server to any group
iptables -A OUTPUT -m addrtype --dst-type MULTICAST -j DROP
# Using multiple ports for filter
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT     # Allows HTTP and HTTPS outgoing traffic
# Notice `dports` is plural

# Filter traffic for protocols that dont use ports like ICMP
cat /etc/protocols          # List the protocols and ports
# Dropping all traffic except TCP and UDP
iptables -P INPUT -j DROP       # Policy to drop all traffic by default if no match found
iptables -P OUTPUT -j DROP
iptables -A INPUT -i lo -j ACCEPT       # Allow loopback interface traffic
iptables -A OUTPUT -i lo -j ACCEPT      
iptables -A INPUT -p tcp -j ACCEPT      # Allow tcp traffic
iptables -A OUTPUT -p tcp -j ACCEPT
iptables -A INPUT -p udp -j ACCEPT      # Allow udp traffic
iptables -A OUTPUT -p udp -j ACCEPT

ping 8.8.8.8                # This will be blocked as its ICMP 
dig www.google.com          # This will work as DNS is UDP traffic

# dropping incoming GRE traffic
iptables -A INPUT -p gre -j DROP
# allowing outgoing ICMP traffic
iptables -A OUTPUT -p icmp -j DROP

# Filter traffic based on interface (LAN, WLAN)
# dropping ssh traffic that's coming on eth0 interface (suppose it's external)
iptables -A INPUT -p tcp --dport 22 -i eth0 -j DROP
# allowing ssh traffic that's coming on eht1 interface (suppose it's internal)
iptables -A INPUT -p tcp --dport 22 -i eth1 -j ACCEPT
# allowing outgoing https traffic via eth1
iptables -A OUTPUT -p tcp --dport 443 -o eth1 -j ACCEPT

# Filter traffic based out of Negation
# This is easy to whitelist one IP
# This will drop all HTTPS traffic except that coming from 0.3 IP address
iptables -A INPUT ! -s 192.168.0.3 -p tcp --dport 443 -j DROP
# dropping all incoming ssh traffic accepting packets from 100.0.0.1 (management station)
iptables -A INPUT -p tcp --dport 22 ! -s 100.0.0.1 -j DROP
# dropping all outgoing https traffic excepting to www.linux.com
iptables -A OUTPUT -p tcp --dport 443 ! -d www.linux.com -j DROP
# dropping all communication excepting that with the default gateway (mac is b4:6d:83:77:85:f4)
iptables -A INPUT -m mac ! --mac-source b4:6d:83:77:85:f4 -j DROP
# The DNS Server of your LAN is set to 8.8.8.8. You don't want to allow the users of the LAN to change the DNS server.
iptables -A FORWARD -p udp --dport 53 ! -d 8.8.8.8 -j DROP

# Filter traffic based on tcp flags
# dropping all incoming tcp packets that have syn set
iptables -A INPUT -p tcp --syn -j DROP
# logging outgoing traffic that has syn and ack set
iptables -A OUTPUT -p tcp --tcp-flags syn,ack,rst,fin syn,ack -j LOG
# Allow establishing incoming ssh (tcp/22) connections only from the LAN. 
# The internal interface is called eth0 and the external interface is called eth1.
iptables -A FORWARD -p tcp --dport 22 --syn -i eth0 -j ACCEPT
iptables -A FORWARD -p tcp --dport 22 --syn -i eth1 -j DROP
# Drop all linux router outgoing packets of type tcp (port 80 and 443) to www.linuxquestions.org
iptables -A FORWARD -p tcp --dport 80 -d www.linuxquestions.org -j DROP
iptables -A FORWARD -p tcp --dport 443 -d www.linuxquestions.org -j DROP

# Connection Tracking
# connection tracking = Stateful firewall = better than stateless and is secure
# connection tracking can be used even if the protocol is itself stateless (ex: ICMP, UDP)
# Netfilter is a Stateful firewall
##################
# Example of a Stateful Firewall for a Desktop
##################
#!/bin/bash
iptables -f
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT i lo -j ACCEPT

iptables -A INPUT -m state --state INVALID -j DROP      # All invalid state connections are blocked
iptables -A OUTPUT -m state --state INVALID -j DROP

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT  # All valid state connections are allowed
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT # Allow new connections

iptables -P INPUT -j DROP       # Drop any other connections to desktop
iptables -P OUTPUT -j DROP
##################

# Test the Stateful firewall
# Open Browser and test a https website
# SSH connection to and from the Desktop
# Ping and SSH from another machine to Desktop --> This will be dropped as NEW connection is dropped in INPUT
# Selectively allow SSH action from the network, add it before INVALID
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -s 192.168.0.20 -j ACCEPT
# OR
iptables -A INPUT -p tcp --dport 22 --syn -s 192.168.0.20 -j ACCEPT
##################

# Filter using Date and Time
date            # Check the current date and timezone of the server
# Permit SSH From Mon to Fri between 10 AM to 4 PM
iptables -A INPUT -p tcp --dport 22 -m time --timestart 10:00 --timestop 16:00 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP
# Permit access to website after working hours 
iptables -A INPUT -p tcp --dport 443 -d www.ubuntu.com -m time --timestart 18:00 --timestop 8:00 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -d www.ubuntu.com -j DROP

# DoS protection by Connlimit module
iptables -A INPUT -p tcp --dport 25 --syn -m connlimit --connlimit-above 5 -j REJECT --reject-with tcp-rst
# This rejects and drops conections coming the same IP after 5 TCP connections and resets the connections.

# DoS protection by implementing Rate limiting
# default limit-burst is 5 and is the allowed packets to be matched from same IP in a single burst,
# after this the "limit" value is the next allowed value once burst is exhausted
# Limit ICMP packets from one IP, max 7 packets per sec and then apply rate limit of 1 per sec
iptables -A INPUT -p icmp --icmp-type echo-request -m limit 1/sec --limit-burst 7 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# Testing the icmp rule
# Run tcdump on the server terminal
tcpdump icmp -n  # This shows only icmp traffic and IP addresses
# In the second server, ping the icmp server with 10 request per sec
ping -i 0.1 192.168.0.10        # Interval
# Output on ping server, after 7 packets, rate drops to 1 packet per sec

# Allow only 5 new incoming connections per second to port 443 (https) 
iptables -A INPUT -p tcp --dport 443 --syn -m limit --limit 5/sec -j ACCEPT
iptables -A INPUT -p tcp --dport 443 --syn -j DROP

# Dynamic Blacklist Database Creation - Using recent match
# Recent match options:
# --name: creates a list in which the source IP address will be added and checked.
# --set: adds the source IP address to the list.
# The list with blacklisted IP addresses is found in: /proc/net/xt_recent/LIST_NAME

# Example to blacklist IP for 60 sec, when port 25 is accessed between 8AM to 10 PM
iptables -A INPUT -m recent  --name hackers --update --seconds 60 -j DROP
# Above rule will update the hackers list with recent timestamp when a new request comes from same IP
# when a packet is coming, it will be checked against this rule and
# if its source ip belongs to the hacker list, the packet will be dropped
# last seen time is updated with another 60 seconds (the source ip address stays in the list for another 60 seconds)
iptables -A INPUT -p tcp --dport 25 -m time --timestart 8:00 --timestop 22:00 \
-m recent -name hackers --set -j DROP
# when the 1st matched packet arrives (tcp/25 between 8:00-10:00 UTC), a list named hacker is created,
# the source ip address of the packet is added to that list and the packet is dropped

#Testing Backlist process
# Second server, open 2 terminals
# Terminal 1, run ping, Terminal 2 start NMAP to scan port 25. 
# As soon as NMAP is run, ping output is stopped as server 2 is added to blacklist
nmap -p 25 192.168.0.10
# Display the blacklist on server 1
cat /proc/net/xt_recent/hackers
# After 60 secs after ping output is stopped, running ping again starts working, till nmap is not run again

# Filter Output using Quotas
# --quota - Data in bytes
# Allow one server to download 1GB from website
iptables -A OUTPUT -d 80.0.0.1 -p tcp --sport 80 -m quota --quota 1000000000 -j ACCEPT
iptables -A OUTPUT -d 80.0.0.1 -p tcp --sport 80 -j DROP
# Allow serverto accept only 10Mb from another server
iptables -A INPUT -s 192.168.0.20 -p tcp --dport 80 -m quota --quota 10000000 -j ACCEPT
iptables -A INPUT -s 192.168.0.20 -p tcp --dport 80 -j DROP

# Testing the quota rule
# in Server 2, check for a file with size more than 20Mb
ls -lSh file.tar                 # Gives the size of the file
scp file.tar root@192.168.0.10:~ # Copy the file to server 1 home directory
# On server1, the transfer stops after 10Mb
iptables -vnL                    # Shows only 10Mb is copied
ls ~                             # Shows partial file

# ipset
# "ipset" is an extension to iptables that allows us to create a firewall that match entire "sets"
# of addresses at once.
# IP sets are stored in indexed data structures instead of chains which are stored & traversed linearly.
sudo apt install ipset              # Install ipset
ipset -N myset hash:ip              # Creates a new set containing IP data
ipset -A myset 1.1.1.1              # Adding data to the set
ipset -A myset 2.2.2.2
ipset -A myset 8.8.8.8

# Add a rule to drop packets from myset in iptables
iptables -A INPUT -m set --match-set myset src -j DROP
# Test the rule
ping 8.8.8.8                        # Will fail

# Adding a network to ipset
ipset -N china hast:net -exist      # Creates a new set or ignores if it already exist
ipset -A china 1.0.0.0/8 -exist     # Adds entry to set or ignores if alreadt exist
ipset -L                            # List the sets
ipset -L china                      # Displays china set
ipset -D china 1.0.0.0/8            # Deletes the entry from china set
ipset -F china                      # Deletes all entries from china set
ipset -F                            # Flushes all entries from all sets
ipset -X china                      # Deletes the set china
# Delete will not work, if the set is referenced in an iptable. Delete the reference, then delete the set.

# Dynamic Blacklist Database Creation - Using ipset
ipset -N auto_blocked hast:ip -exist 
iptables -I INPUT -p tcp --dport 80 -j SET --add-set auto_blocked src # Adding IP to blocked set
iptables -I INPUT -m set --match-set auto_blocked src -j DROP # Adding rule to block the IP set
#Testing Backlist process
# Second server, open 2 terminals
# Terminal 1, run ping, Terminal 2 start tenet to send request to port 80. 
# As soon as telnet is run, ping output is stopped as server 2 is added to blacklist
telnet 192.168.0.20 80

# Block all IPs and Networks From File
# a file called bad_hosts.txt exists in the same directory with the script and 
# contains IPs and Networks, one per line like:
# 11.0.0.16
# 8.8.8.8
# 1.2.3.4
# 192.0.0.0/16

#!/bin/bash
# File that contains the IPs and Nets to block
FILE="bad_hosts.txt"
 # Creating a new set
ipset -N bad_hosts iphash -exist
 # Flushing the set if it exists
ipset -F bad_hosts
echo "Adding IPs from $FILE to bad_hosts set:"
for ip in `cat $FILE`
do
	ipset -A bad_hosts $ip
	echo -n "$ip "
done 
# Adding the iptables rule that references the set and drops all ips and nets
echo -e -n "\nDropping with iptables... "
iptables -I INPUT -m set --match-set bad_hosts src -j DROP
echo "Done"

# Blocking Countries
#!/bin/bash
# Check if the file exists (in the current directory) and if yes, remove it
if [ -f "cn-aggregated.zone" ]
then
	rm cn-aggregated.zone
fi
# Download the aggregate zone file for China
wget http://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone
# Check if there was an error
if [ $? -eq 0 ]
then
	echo "Download Finished!"
else
    echo "Download Failed! Exiting ..."
    exit 1 
fi
# Creating a new set called china of type hash:net (nethash)
ipset -N china hash:net -exist
# Flushing the set
ipset -F china
# Iterate over the Networks from the file and add them to the set
echo "Adding Networks to set..."
for i in `cat cn-aggregated.zone`
do
	ipset -A china $i
done
# Adding a rule that references the set and drops based on source IP address
echo -n "Blocking CN with iptables ... "
iptables -I INPUT -m set --match-set china src -j DROP
echo "Done"
```
## Target Example
```BASH
# netstat
apt install net-tools       # Installs netstat
netstat -tupan              # Shows 't'cp, 'u'dp 'p'rotocols and 'a'll the services that are using the ports
# nmap
apt install nmap            # Installs nmap
nmap -sS 192.168.0.20       # Performs tcp sync scan. Scans only 1000 ports
nmap -p- 192.168.0.20       # Performs all ports scan (0-65535)
nmap -p 80,50005 -sV 192.168.0.20   # Specify ports to scan and display the service that is running
nmap -sP 192.168.0.0/24     # Ping scanning (entire Network)
nmap -sS 192.168.0.0/24 --exclude 192.168.0.10 # Excluding an IP
nmap -oN output.txt 192.168.0.1 # Saving the scanning report to a file
nmap -A -T aggressive cloudflare.com # -A OS and service detection with faster execution

# Reject
# It is efficient to REJECT than DROP targets.
iptables -j REJECT --help       # Shows reject-with types

# Reject SSH traffic and test it
iptables -A INPUT -p tcp --dport 22 -s 192.168.0.10 -j REJECT --reject-with tcp-reset
# start tcpdump to trace the output on server 1
tcpdump host 192.168.0.10 -n    # Shows incoming traffic from ssh client
# In client server, run nmap to scan port 22
nmap -p 22 192.168.0.20 

# reject all incoming ICMP ping packets that are not coming from 10.0.0.1 (management station)
iptables -A INPUT ! -s 10.0.0.1 -p icmp --icmp-type echo-request -j REJECT --reject-with admin-prohib

# Log
# Logging detailed info about the packet contents.
# Will be shown in dmesg command to show the kernel logs that are in memory. Will be lost at server restart.
tail -f /var/log/kern.log       # Shows the kernel logs that are persisted even after restart.

# logging the first packet (tcp syn set) of any incoming ssh connection
# use the prefix: ###ssh:
iptables -A INPUT -p tcp --syn --dport 22 -j LOG --log-prefix="##ssh:" --log-level info
# filtering logs by prefix
dmesg | grep "##ssh:" 
# logging only 10 incoming ICMP ping packets per minute
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 10/minute -j LOG --log-prefix="ping probe:"

# Tee
# Allows you to mirror incoming traffic on one server to another server
# mirror all TCP traffic that arrives at 10.0.0.10 to 10.0.0.1.
iptables -A INPUT -p tcp -j TEE --gateway 10.0.0.1
# Testing
# Open tcpdump on server 1, From third server ping server 2. tcpdump will show packets coming on server 2

# Redirect
# Allows you to transparently proxy a service on a server
# Redirect incoming TCP traffic to port 80 to port 8080 on the same host where a Proxy is running.
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
```

## NAT and Port Forwarding Examples
```BASH
# SNAT replaces the private IP address from the packet with the public IP address
# of the router external interface.
# SNAT helps private servers to access the internet via a router IP.
# Example to make the linux server as a Router
#!/bin/bash
 # flush the nat table of all chains
iptables -t nat -F
# enable routing process
echo "1" > /proc/sys/net/ipv4/ip_forward
 # define rules that match traffic that should be NATed
# we perform NAT for the entire subnetwork
# enp0s3 is the external interface
# 80.0.0.1 is the public & static ip address
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp0s3 -j SNAT --to-source 80.0.0.1
# OR
# if the public IP address is dynamic we use MASQUERADE instead of SNAT
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp0s3 -j MASQUERADE
# it's not mandatory to perform NAT for entire subnet. We could perform NAT only for some protocols
# Example: we perform NAT only for TCP
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -p tcp -o enp0s3 -j SNAT --to-source 80.0.0.1
# filtering is done on FORWARD CHAIN

# Port Forwarding
# DNAT permits connections from the Internet to servers with private IP addresses inside LAN.
# The client connects to the public IP address of the DNAT Router which in turn
# redirects traﬃc to the private server.
# The server with the private IP address stays invisible.
### PORT FORWARDING (DNAT) ###
#!/bin/bash
# flushing nat filter of PREROUTING chain
iptables -t nat -F  PREROUTING
# all the packets coming to the public IP address of the router and port 80 
# will be port forwarded to 192.168.0.20 and port 80
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.20
## VARIANTS
# 1.redirect port 8080 on router to port 80 on the private web-server 
# Internet clients connect to the public IP address of the router and port 8080 and the packets are 
# redirected to the private server with 192.168.0.20 and port 80
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.0.20:80
#2. Load-Balancing
# On all 5 private servers (192.168.0.20-192.168.0.24)run the same service (e.g. HTTPS)
# The router will pick-up a random private IP from the range and then translate and send (port-forward) the packet to that IP
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.0.20-192.168.0.24

##** LOAD BALANCE NAT TRAFFIC OVER 2 INTERNET CONNECTIONS WITH DYNAMIC IP ADDRESSES **##
#!/bin/bash
# Traffic that goes over the first ISP connection
# web: 80 443
# email: 25 465 143 993 110 995
# ssh: 22
ISP1="22 25 80 110 143 443 465 993 995"
# flushing nat table and POSTROUTING chain
iptables -t nat -F POSTROUTING
# enable routing
echo "1" > /proc/sys/net/ipv4/ip_forward 
for port in $ISP1
do
    iptables -t nat -A POSTROUTING -p tcp --dport $port -o eth1 -j MASQUERADE
done
# Traffic not NATed goes over the 2nd ISP connection
iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE
```
## Custom Defined Chain Examples
```BASH
# creating a user-defined chain
iptables -N TCP_TRAFFIC 
# add rules to the chain
iptables -A TCP_TRAFFIC -p tcp -j ACCEPT
# jump to the chain from the input chain
iptables -A INPUT -p tcp -j TCP_TRAFFIC
# flush all rules in the chain
iptables -F TCP_TRAFFIC
# flush all rules otherwise custom chain can't be deleted
iptables -F 
# delete the chain
iptables -X TCP_TRAFFIC
```
## Chain Traversal Order
```BASH
# Incoming Packet Traversal
# Packet comes from the Network and is destined for our host, which is the final destination
PREROUTING --> INPUT
# Packet comes from the Network and must be routed by the Linux machine
PREROUTING --> FORWARD --> POSTROUTING
# Outgoing Packet Traversal
# Packet is generated by an Application on the host
LOCAL APPLICATION --> OUTPUT --> POSTROUTING
```
## TCP Wrappers
- Host-based networking ACL system.
- Controls access to “wrapped” services.
- A wrapped service is compiled with `libwrap` support.
- Check if a service supports wrappers use `ldd`.
```BASH
ldd /usr/sbin/sshd | grep libwrap           # Prints required shared libraries.
```
- Can control access by IP address / networks.
- Can control access by hostname.
- Transparent to the client and service.
- Used with xinetd which is a super daemon as it can manage a lot of smaller services, secures access to your server.
- Centralized management for multiple network services.
- Runtime configuration
### Configuring TCP Wrappers
- `/etc/hosts.allow` is checked first. If a match is found, **access is granted**.
- `/etc/hosts.deny` is checked next. If a match is found, **access is denied**.
### Access Rules
- The rule format for `hosts.allow` and `hosts.deny` are the same.
- One rule per line
- Format: `SERVICE(S) : CLIENT(S) [: ACTION(S) ]`
```BASH
# Deny All configuration
# /etc/hosts.deny:
ALL : ALL                                       # Deny all connections
# /etc/hosts.allow:
# Explicitly list allowed connections here.
sshd : 10.11.12.13                              # Allow only ssh connection from this ip

# Additional configuration possibilities
sshd, imapd : 10.11.12.13                       # Multiple services allowed
ALL : 10.11.12.13                               # Wild Card configuration
sshd : 10.11.12.13, 10.5.6.7                    # Multiple IPs
sshd : jumpbox.example.com                      # Domain name
sshd : .admin.example.com                       # Subdomain - server2.admin.example.com or webdev.admin.example.com
sshd : jumpbox*.example.com                     # jumpbox4admins.example.com
sshd : jumpbox0?.example.com                    # jumpbox03.example.com
sshd : 10.11.12.                                # Subnet range
sshd : 10.                                      
sshd : 10.11.0.0/255.255.0.0
sshd : /etc/hosts.sshd                          # Allow all hosts in this file
imapd : ALL                                     # Wildcard in clients
sshd : ALL EXCEPT .hackers.net                  # Conditions, except IP in hacker.net domains
sshd : 10.11.12.13 : severity emerg             # Actions - Log emergency messages for that ssh connection coming from IP
sshd : 10.11.12.13 : severity local0.alert      # Raise local alert
# Raise custom message
# /etc/hosts.deny:
sshd : .hackers.net : spawn /usr/bin/wall “Attack in progress.”
# Use expressions in message, %a logs client ip
sshd : .hackers.net : spawn /usr/bin/wall “Attack from %a.”

## Possible expression expansions
# %a (%A) The client (server) host address.
# %c      Client information.
# %d      The daemon process name.
# %h (%H) The client (server) host name or address.
# %n (%N) The client (server) host name.
# %p      The daemon process id.
# %s      Server information.
# %u      The client user name (or "unknown").
# %%      Expands to a single `% ́ character.
```