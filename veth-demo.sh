#!/bin/bash
# this script must be run as root

# create ovs bridge in root namespace
ovs-vsctl add-br ovs1

# create veth pairs in root namespace,
# move to connect red namespace
# and ovs bridge
ip link add eth0-r type veth peer name veth-r
ip link set eth0-r netns red
ip netns exec red ip link list
ovs-vsctl add-port ovs1 veth-r
ovs-vsctl show

# create another pair to connect blue namespace
# and ovs bridge
ip link add eth0-b type veth peer name veth-b
ip link set eth0-b netns blue
ip netns exec blue ip link list
ovs-vsctl add-port ovs1 veth-b
ovs-vsctl show

# veth-r and veth-b are in root namespace
ip link list
ip link set dev veth-r up
ip link set dev veth-b up

# bring loopback in red namespace
ip netns exec red ping localhost
ip netns exec red ip link set dev lo up
ip netns exec red ping localhost

# set static ip address in red namespace
ip netns exec red ip link set dev eth0-r up
ip netns exec red ip address add 10.0.0.1/24 dev eth0-r

# check red namespace has route via eth0-r
ip netns exec red ip route

# root namespace doesnt aware of 10.0.0.0/24 network
ip route

# bring up same thing in blue namespace
ip netns exec blue ip link set dev lo up
ip netns exec blue ip link set dev eth0-b up
ip netns exec blue ip address add 10.0.0.2/24 dev eth0-b

# check blue namespace has route via eth0-b
ip netns exec blue ip route

# test pinging blue from red namespace
ip netns exec red ping 10.0.0.2 -c 2

# test pinging red from blue namespace
ip netns exec blue ping 10.0.0.1 -c 2

# run netcat server in blue namespace
ip netns exec blue nc -l 4000

# accessible from red namespace
ip netns exec blue nc 10.0.0.2 4000

# accessible from blue namespace (loopback)
ip netns exec red nc 10.0.0.2 4000

# not accessible from root namespace
nc 10.0.0.2 4000

# find nc PID
pid=$(ps -ef | grep -m1 nc | cut -d ' ' -f 7)
ip netns identify ${pid}
