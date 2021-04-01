
# Create config files
tee -a /etc/radvd.conf <<EOF
interface vpeer-router { 
        AdvSendAdvert on;
        MinRtrAdvInterval 3; 
        MaxRtrAdvInterval 10;
        prefix 2001::/64 { 
                AdvOnLink on; 
                AdvAutonomous on; 
                AdvRouterAddr on; 
        };
};
interface veth3 { 
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
ip link add name veth1 type veth peer name vpeer1
ip link add name veth2 type veth peer name vpeer2
ip link add name veth3 type veth peer name vpeer3
ip link add name veth-router type veth peer name vpeer-router
brctl addbr sw1

# Set peer link up
ip link set veth1 up
ip link set veth2 up
ip link set veth3 up
ip link set veth-router up
ip link set sw1 up

# Assign interfaces to namespaces 
ip link set dev vpeer1 netns h1
ip link set dev vpeer2 netns h2
ip link set dev vpeer3 netns h3
ip link set dev vpeer-router netns r1
ip link set dev veth3 netns r1

# Connect veth to bridge
brctl addif sw1 veth1
brctl addif sw1 veth2
brctl addif sw1 veth-router

# Configure router as router
ip netns exec r1 sysctl -w net.ipv6.conf.all.forwarding=1


# Configure IP addresses
ip netns exec r1 ip -6 addr add 2001::113/64 dev vpeer-router
ip netns exec r1 ip -6 addr add 2002::111/64 dev veth3

# Set Up interfaces
ip netns exec h1 ip link set lo up
ip netns exec h2 ip link set lo up
ip netns exec h3 ip link set lo up
ip netns exec r1 ip link set lo up

ip netns exec h1 ip link set vpeer1 up
ip netns exec h2 ip link set vpeer2 up
ip netns exec h3 ip link set vpeer3 up
ip netns exec r1 ip link set veth3 up
ip netns exec r1 ip link set vpeer-router up

# Init router advertisement daemon
ip netns exec r1 radvd -n


