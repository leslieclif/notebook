#!/bin/bash

echo -n 'Enter the IP or Network Address: '
read IP

echo -n  'Enter DROP or ACCEPT: '
read ANSWER

if [ $ANSWER = "DROP" ]
then	
	iptables -I INPUT -s $IP -j DROP
	echo  "Traffic from $IP has been dropped"
elif [ $ANSWER = "ACCEPT" ]
then 
	
	iptables -I INPUT -s $IP -j ACCEPT
	echo  "Traffic from $IP has been accepted"
else
	echo  "Invalid option. Enter DROP or ACCEPT"
fi 
