#!/bin/bash

# Creating a new set called myset of type iphash (hash:ip) -> -N or create
# Another useful type is nethash or hash:net
# -exist -> no error if it already exists
ipset -N myset iphash -exist


# Adding IPs to the set (-A or add)

ipset -A myset 1.2.3.4
ipset add myset 4.3.2.1
ipset -A myset 3.2.1.4
ipset -A myset 3.2.1.4 -exist # -exist -> no error if the entry already exists in the set


# Reference the set in a match specification of iptables
# DROP on source
iptables -A INPUT -m set --match-set myset src -j DROP


# Listing set entries (-L or list)
ipset list  # => lists all sets with all entries
ipset -L myset # => lists only that set
ipset -L -n 	# => lists only the set names


# Deleting an entry from a set (-D or del)
ipset -D myset 1.2.3.4
ipset del myset 4.3.2.1


# Flushing all entries from a set or from all sets (-F or flush)
ipset -F myset # => flushing all entries from myset 
ipset -F   # => flushing all entries from all sets

# Setting the maximal number of elements which can be stored in a set (default value: 65535) 
ipset create myset1 hash:ip maxelem 2048


# Destroying a set (-X or destroy)
ipset destroy myset
ipset -X 	# => destroying all sets

# Note: a set cannot be destroyed while there is a single reference pointing to it. 
