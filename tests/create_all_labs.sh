#!/bin/bash

ans="ansible-playbook lab_setup.yml -t provision -i"

$ans inventories/bipod/hosts
$ans inventories/ccna/hosts
$ans inventories/ccnp/01_01_02_inter_vlan_routing/hosts
$ans inventories/custom/ccna_remote/hosts
$ans inventories/custom/etherchannel/hosts
$ans inventories/custom/ospf_multiarea/hosts
$ans inventories/custom/ospf_neighbors/hosts
$ans inventories/custom/osseclab/hosts
$ans inventories/custom/startup_ios/hosts
$ans inventories/custom/startup_linux/hosts
$ans inventories/custom/tripod_l2/hosts
$ans inventories/gateway/hosts
$ans inventories/networking_workshop/hosts
$ans inventories/router_on_a_stick/hosts
$ans inventories/switchblock/hosts
$ans inventories/tripod/hosts
