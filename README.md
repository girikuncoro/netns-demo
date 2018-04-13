## Linux network namespace demo  
This repo attempts to demonstrate how container (e.g. Docker, rkt, LXC) isolates networking, despite its kernel sharing. The isolation is typically done through Linux network namespace. As described in [wikipedia](https://en.wikipedia.org/wiki/Linux_namespaces), namespaces are a feature of the Linux kernel that partitions kernel resources such that one set of processes sees one set of resources while another set of processes sees a different set of resources. 

Network namespaces virtualize the network stack. On creation a network namespace contains only a loopback interface. Each network interface (physical or virtual) is present in exactly 1 namespace and can be moved between namespaces. Each namespace will have a private set of IP addresses, its own routing table, socket listing, connection tracking table, firewall, and other network-related resources. On its destruction, a network namespace will destroy any virtual interfaces within it and move any physical interfaces back to the initial network namespace.

## How to learn from this repo  
The demo is based on Bob Lintz's seminar at Stanford and credit to David Mahler's [video](https://www.youtube.com/watch?v=_WgUwUf1d34). By using [ip netns](http://man7.org/linux/man-pages/man8/ip-netns.8.html) command, Linux network namespace is demonstrated. 

The demo contains 3 parts:
* 01 - [What does network namespace do](https://github.com/girikuncoro/netns-demo/blob/master/01-namespace-demo.sh): each namespace has its own network interfaces, route table, arp table, etc.
* 02 - [How do 2 network namespaces communicate to each other](https://github.com/girikuncoro/netns-demo/blob/master/02-veth-demo.sh): communicate to each other using [ovs-switch](https://www.openvswitch.org/) and [veth pair](http://man7.org/linux/man-pages/man4/veth.4.html).
* 03 - [How multitenancy of multiple namespaces works](https://github.com/girikuncoro/netns-demo/blob/master/03-dhcp-demo.sh): proof multitenancy between multiple namespaces with [vlan](https://en.wikipedia.org/wiki/Virtual_LAN), by running 2 [dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq) processes in separate namespace.

The comment is included in each command to explain what it does. It would be helpful to try out all commands in your Linux machine, by reviewing the [slides](https://slides.com/girikuncoro/linux-network-namespace/live#/) as well that include network topology of the demo.

## Prerequisites  
The demo depends on `ovs-switch` and `dnsmasq`, install in your machine by running `install-deps.sh` or install yourself.

Enjoy!
