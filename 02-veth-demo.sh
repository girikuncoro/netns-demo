#!/bin/bash
# each command must be run as root, try to run manually each command. we would like to
# see connectivity between 2 different network namespaces via ovs bridge.

# create ovs bridge in root namespace. this will be used to connect red and blue namespaces.
ovs-vsctl add-br ovs1

# create veth pairs in root namespace, move to connect red namespace and ovs bridge. veth pair
# is like a pipe with 2 network interfaces, such that packet from one end will flow to another
# end.
ip link add eth0-r type veth peer name veth-r

# move eth0-r interface to red namespace.
ip link set eth0-r netns red
ip netns exec red ip link list

# connect veth-r to ovs bridge. with this, ovs bridge and red namespace are connected, but
# both interfaces are still down.
ovs-vsctl add-port ovs1 veth-r
ovs-vsctl show

# create another pair to connect blue namespace and ovs bridge.
ip link add eth0-b type veth peer name veth-b

# move eth0-b interface to blue namespace.
ip link set eth0-b netns blue
ip netns exec blue ip link list

# connect veth-b to ovs bridge. with this, ovs bridge and blue namespace are connected, but
# both interfaces are still down.
ovs-vsctl add-port ovs1 veth-b
ovs-vsctl show

# bring up veth-r and veth-b in root namespace.
ip link list
ip link set dev veth-r up
ip link set dev veth-b up

# bring up loopback in red namespace. verify that localhost is not pinging in red namespace
# since loopback interface is down, and pinging once we bring it up.
ip netns exec red ping localhost
ip netns exec red ip link set dev lo up
ip netns exec red ping localhost

# set static ip address in red namespace.
ip netns exec red ip link set dev eth0-r up
ip netns exec red ip address add 10.0.0.1/24 dev eth0-r

# check red namespace has route via eth0-r.
ip netns exec red ip route

# root namespace doesnt aware of 10.0.0.0/24 network.
ip route

# bring up same thing in blue namespace, assign with different static ip
# same subnet.
ip netns exec blue ip link set dev lo up
ip netns exec blue ip link set dev eth0-b up
ip netns exec blue ip address add 10.0.0.2/24 dev eth0-b

# check blue namespace has route via eth0-b.
ip netns exec blue ip route

# test pinging blue from red namespace, this proof connectivity between
# red and blue namespaces via ovs bridge.
ip netns exec red ping 10.0.0.2 -c 2

# test pinging red from blue namespace.
ip netns exec blue ping 10.0.0.1 -c 2

# to make it more interesting, run netcat server in blue namespace, listen to
# port 4000.
ip netns exec blue nc -l 4000

# try running netcat client from blue namespace and send message. this proves
# loopback interface works in blue namespace.
ip netns exec blue nc 10.0.0.2 4000

# try running netcat client from red namespace and send message. this proves
# connectivity between red and blue namespaces.
ip netns exec red nc 10.0.0.2 4000

# try running netcat client on root namespace. netcat server is not accessible 
# from root namespace, which proves network isolation works.
nc 10.0.0.2 4000

# we can find out a process is owned by which network namespace. find the nc PID,
# and see that nc process is owned by blue namespace.
pid=$(ps -ef | grep -m1 nc | cut -d ' ' -f 7)
ip netns identify ${pid}
