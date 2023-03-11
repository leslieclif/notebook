#!/bin/bash

echo "### BLOCKING ALL IPs AND NETWORKS FROM FILE."

# a file called bad_hosts.txt exists in the same directory with the script and 
# contains IPs and Networks, one per line like:
# 11.0.0.16
# 8.8.8.8
# 1.2.3.4
# 192.0.0.0/16



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
