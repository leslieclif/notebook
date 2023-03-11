#!/bin/bash

echo "### BLOCKING CHINA ###"


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
