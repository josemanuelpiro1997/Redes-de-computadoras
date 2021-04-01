#!/bin/bash

#Clear environment 
ip netns delete h1 
ip netns delete h2 
ip netns delete h3
ip netns delete r1
ip link delete veth-R-2
ip link delete veth-R-1
ip link delete veth1
ip link delete veth2
ip link delete veth3
ip link delete vpeer2
ip link delete vpeer3
ip link delete vpeer-router
ip link set sw1 down
brctl delbr sw1
rm /etc/radvd.conf
