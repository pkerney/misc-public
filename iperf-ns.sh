# Do all this as root. Need two windows.
# Execute the variables in both windows. And only the “client” command in the second window.

# variables
NS_1="ns_server"
NS_2="ns_client"
DEV_1="eno1np0"
DEV_2="eno2np1"
SN=24
IP_1="192.168.1.10"
IP_2="192.168.1.11"
IPSN_1="${IP_1}/${SN}"
IPSN_2="${IP_2}/${SN}"
# end variables

# Create namespaces (all done with required permissions, e.g. as root):

ip netns add $NS_1
ip netns add $NS_2
ip netns list

# Note that the interfaces status / config must now be accessed within the context of the assigned namespace - so they won't appear if you run a naked ip link as this is run #in the context of the default namespace. Running a command within a namespace can be done using

#ip $NS_1 exec <namespace-name> <command>
#as prefix.

#Now assign namespaces to interfaces, apply config and set interfaces up:

ip link set $DEV_1 netns $NS_1
ip netns exec $NS_1 ip addr add dev $DEV_1 $IPSN_1
ip netns exec $NS_1 ip link set dev $DEV_1 up
ip link set $DEV_2 netns $NS_2
ip netns exec $NS_2 ip addr add dev $DEV_2 $IPSN_2
ip netns exec $NS_2 ip link set dev $DEV_2 up

#Now you can execute the applications within the namespace - for the iperf server run
ip netns exec $NS_1 iperf -s -B $IP_1

#and the client:
ip netns exec $NS_2 iperf -f g -i 1 -c $IP_1 -B $IP_2

#The traffic will now be sent via the physical interfaces as the whole network stack, interface, routing ... is isolated by the namespaces so the kernel is not able to match #the addresses used within the traffic with local (available) interfaces.

#If you are done with your experiments simply delete the namespaces:

ip netns del $NS_1
ip netns del $NS_2
#The interfaces will be reassigned to the default namespace and all configuration done within the namespace disappears (e.g. no need to delete assigned IP addresses).
