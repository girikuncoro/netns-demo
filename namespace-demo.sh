#!/bin/bash
# this script must be executed as root

# create red and blue network namespace
ip netns add red
ip netns add blue

# list network namespace
ip netns list
ls /var/run/netns

# root namespace, red, and blue
# have different network interfaces
ip link list
ip netns exec red ip link list
ip netns exec blue ip link list

# root namespace, red and blue
# have different route table
ip route
ip netns exec red ip route
ip netns exec blue ip route

# root namespace, red and blue
# have different arp table
arp
ip netns exec red arp
ip netns exec blue arp

# each namespace has net assigned to
# different inode
ls -l /proc/self/ns
ip netns exec red ls -l /proc/self/ns
ip netns exec blue ls -l /proc/self/ns