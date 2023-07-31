#!/bin/bash
# Script for routing between ERP-EDGE and DEFAULT-EDGE

IP_ERP=$1
IP_ERP_EDGE=$2
IP_DEFAULT_EDGE=$3
IP_ROUTER_LAN_DEFAULT=$4
IP_ROUTER_LAN_ERP=$5
INT_ROUTER_LAN_DEFAULT=eth1
INT_ROUTER_LAN_ERP=eth2

reset_routes(){
    sudo ip route del default
    sudo ip route del $IP_ERP
}

default_edge_unavailable(){
    reset_routes
    # default route by ERP-EDGE
    sudo ip route add default via $IP_ERP_EDGE src $IP_ROUTER_LAN_ERP dev $INT_ROUTER_LAN_ERP
}

erp_edge_unavailable(){
    reset_routes
    # default route by DEFAULT-EDGE
    sudo ip route add default via $IP_DEFAULT_EDGE src $IP_ROUTER_LAN_DEFAULT dev $INT_ROUTER_LAN_DEFAULT
}

normal_case(){
    reset_routes
    # default route
    sudo ip route add default via $IP_DEFAULT_EDGE src $IP_ROUTER_LAN_DEFAULT dev $INT_ROUTER_LAN_DEFAULT
    # static route to ERP
    sudo ip route add $IP_ERP via $IP_ERP_EDGE src $IP_ROUTER_LAN_ERP dev $INT_ROUTER_LAN_ERP
}

main(){
    # Test ERP-EDGE
    ping -c 3 -t 1 $IP_ERP_EDGE > /dev/null
    STATUS_ERP_EDGE=$?
    # Test DEFAULT-EDGE
    ping -c 3 -t 1 $IP_DEFAULT_EDGE > /dev/null
    STATUS_DEFAULT_EDGE=$?
    # Check test results
    if [ $STATUS_ERP_EDGE -eq 0 ] && [ $STATUS_DEFAULT_EDGE -eq 0 ]; then
        normal_case
        echo "### SUCCESS ###"
        echo "Distributing traffic between ERP-EDGE ($IP_ERP_EDGE) and DEFAULT-EDGE ($IP_DEFAULT_EDGE)."
    elif [ $STATUS_ERP_EDGE -ne 0 ] && [ $STATUS_DEFAULT_EDGE -eq 0 ]; then
        erp_edge_unavailable
        echo "### ATTENTION ###"
        echo "ERP-EDGE unavailable, redirecting all traffic to DEFAULT-EDGE ($IP_DEFAULT_EDGE)."
    elif [ $STATUS_ERP_EDGE -eq 0 ] && [ $STATUS_DEFAULT_EDGE -ne 0 ]; then
        default_edge_unavailable
        echo "### ATTENTION ###"
        echo "DEFAULT-EDGE unavailable, redirecting all traffic to ERP-EDGE ($IP_ERP_EDGE)."
    else
        normal_case
        echo "### ERROR ###"
        echo "Both edges are unavailable."
        exit 1
    fi
    exit 0
}

### entrypoint
main
