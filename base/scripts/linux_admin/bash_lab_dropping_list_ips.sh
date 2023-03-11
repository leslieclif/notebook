#!/bin/bash

# IPs to drop (whitespace separated list)
DROPPED_IPS="8.8.8.8 1.1.1.1 10.10.11.1"

# iterating over the list dropping ip after ip
for ip in $DROPPED_IPS
do
        echo "Dropping packets from $ip"
        iptables -I INPUT -s $ip -j DROP
done

# Run the script as: sudo ./script_name.sh
