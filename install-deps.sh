#!/bin/bash
# run this script as root

apt-get upgrade -y
apt-get install -y openvswitch-switch
apt-get install -y dnsmasq