#!/bin/bash
# this script must be run as root

# remove static ip in red and blue namespace
ip netns exec red ip address del 10.0.0.1/24 dev eth0-r
ip netns exec blue ip address del 10.0.0.2/24 dev eth0-b

# add vlan id to ovs bridge for isolation
ovs-vsctl set port veth-r tag=100
ovs-vsctl set port veth-b tag=200

# create two more namespace to run dhcp process
ip netns add dhcp-r
ip netns add dhcp-b

# add internal port with red vlan
ovs-vsctl add-port ovs1 tap-r
ovs-vsctl set interface tap-r type=internal
ovs-vsctl set port tap-r tag=100

# add internal port with blue vlan
ovs-vsctl add-port ovs1 tap-b
ovs-vsctl set interface tap-b type=internal
ovs-vsctl set port tap-b tag=200

# move tap interface to new dhcp red and blue namespace
ip link set tap-r netns dhcp-r
ip link set tap-b netns dhcp-b

# add static ip to tap interface in dhcp red namespace
ip netns exec dhcp-r ip link set dev lo up
ip netns exec dhcp-r ip link set dev tap-r up
ip netns exec dhcp-r ip address add 10.20.30.2/24 dev tap-r

# purposefully add same static ip to tap interface in dhcp blue namespace
# to demonstrate the isolation
ip netns exec dhcp-b ip link set dev lo up
ip netns exec dhcp-b ip link set dev tap-b up
ip netns exec dhcp-b ip address add 10.20.30.2/24 dev tap-b

# run dhcp server in dhcp red namespace
ip netns exec dhcp-r dnsmasq --interface=tap-r --dhcp-range=10.20.30.10,10.20.30.100,255.255.255.0

# run dhcp server in dhcp blue namespace
ip netns exec dhcp-b dnsmasq --interface=tap-b --dhcp-range=10.20.30.10,10.20.30.100,255.255.255.0

# run dhcp client in red namespace
ip netns exec red dhclient eth0-r
ip netns exec red ip address

# run dhcp client in blue namespace
ip netns exec blue dhclient eth0-b
ip netns exec blue ip address
