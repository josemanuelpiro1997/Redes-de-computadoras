#!/bin/bash


# Create config files
tee -a /etc/radvd.conf <<EOF
interface veth-R-1 { 
        AdvSendAdvert on;
        MinRtrAdvInterval 3; 
        MaxRtrAdvInterval 10;
        prefix 2001::/64 { 
                AdvOnLink on; 
                AdvAutonomous on; 
                AdvRouterAddr on; 
        };
};
interface veth-R-2 { 
        AdvSendAdvert on;
        MinRtrAdvInterval 3; 
        MaxRtrAdvInterval 10;
        prefix 2002::/64 { 
                AdvOnLink on; 
                AdvAutonomous on; 
                AdvRouterAddr on; 
        };
};
EOF


# Create resources
ip netns add h1
ip netns add h2
ip netns add h3
ip netns add r1
ip link add name veth1 type veth peer name veth-R-1
ip link add name veth2 type veth peer name vpeer2
ip link add name veth3 type veth peer name vpeer3
ip link add name veth-R-2 type veth peer name vpeer-router
brctl addbr sw1


# Set Up interfaces and peer link
ip link set vpeer2 up
ip link set vpeer3 up
ip link set vpeer-router up
ip link set sw1 up

# Assign interfaces to namespaces 
ip link set dev veth1 netns h1
ip link set dev veth2 netns h2
ip link set dev veth3 netns h3
ip link set dev veth-R-1 netns r1
ip link set dev veth-R-2 netns r1

# Connect peer to bridge
brctl addif sw1 vpeer2
brctl addif sw1 vpeer3
brctl addif sw1 vpeer-router

# Configure router as router ofr IPv6 and IPv4
ip netns exec r1 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec r1 sysctl -w net.ipv4.ip_forward

# Configure IPv4 and IPv6 addresses to router
# to switch
ip netns exec r1 ip -6 addr add 2001:aaaa:bbbb:1::11/64 dev veth-R-1
ip netns exec r1 ip addr add 192.168.1.11/24 dev veth-R-1
# to h3 
ip netns exec r1 ip -6 addr add 2001:aaaa:cccc:1::12/64 dev veth-R-2
ip netns exec r1 ip addr add 192.168.2.12/24 dev veth-R-2


# Configure IP addresses to housts
# h1
ip netns exec h1 ip addr add 192.168.1.10/24 dev veth1
ip netns exec h1 ip -6 addr add 2001:aaaa:bbbb:1::10/64 dev veth1
# h2
ip netns exec h2 ip addr add 192.168.2.10/24 dev veth2
ip netns exec h2 ip -6 addr add 2001:aaaa:cccc:1::10/64 dev veth2
# h3
ip netns exec h3 ip addr add 192.168.2.11/24 dev veth3
ip netns exec h3 ip -6 addr add 2001:aaaa:cccc:1::11/64 dev veth3

# Set Up interfaces
ip netns exec h1 ip link set lo up
ip netns exec h2 ip link set lo up
ip netns exec h3 ip link set lo up
ip netns exec r1 ip link set lo up

ip netns exec h1 ip link set veth1 up
ip netns exec h2 ip link set veth2 up
ip netns exec h3 ip link set veth3 up
ip netns exec r1 ip link set veth-R-1 up
ip netns exec r1 ip link set veth-R-2 up

# add IPv4 and IPv6 default gateways
# h1
ip netns exec h1 ip route add default via 192.168.1.11
ip netns exec h1 ip -6 route add default via 2001:aaaa:bbbb:1::11
# h2
ip netns exec h2 ip route add default via 192.168.2.12
ip netns exec h2 ip route add default via 2001:aaaa:cccc:1::12
# h3 
ip netns exec h3 ip route add default via 192.168.2.12
ip netns exec h3 ip route add default via 2001:aaaa:cccc:1::12


# Init router advertisement daemon
ip netns exec r1 radvd -n