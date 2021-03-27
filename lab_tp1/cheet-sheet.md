# repasar tablas de routeo


- ip netns add {name}  --> create a new network namespace
- ip link add NAME type TYPE [ ARGS ]
  - En este caso utilizaremos el comando de la siguiente manera
    - ip link add DEVICE type { veth | vxcan } [ peer name NAME ] --> create a virtual ethernet whit spacific name
- ip link set { DEVICE | group GROUP } [ { up | down } ] --> change the state of the device to UP or DOWN
- ip link show [ DEVICE | group GROUP ]  -->  display device attributes
- ip link set { DEVICE | group GROUP } [ netns { PID | NETNSNAME } ] --> move the device to the network namespace associated with name
- brctl addbr {name} --> creates a new instance of the ethernet bridge.
- brctl addif {brname} {ifname} -->  will make the interface <ifname> a port of the bridge <brname>