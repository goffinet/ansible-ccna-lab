#!/bin/bash

hostnamectl set-hostname controller
yum -y remove ansible
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install --upgrade pip
pip install ansible
pip install ansible-lint
pip install netaddr
yum -y install git dnsmasq
cat << EOF > /etc/dnsmasq.conf
interface=lo0
interface=eth0
dhcp-range=11.12.13.100,11.12.13.150,255.255.255.0,512h
dhcp-option=3
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
TYPE=Ethernet
IPADDR=11.12.13.1
PREFIX=24
IPV4_FAILURE_FATAL=no
DNS1=127.0.0.1
EOF
systemctl disable systemd-resolved
systemctl stop systemd-resolved
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
chattr +i /etc/resolv.conf
systemctl enable dnsmasq
shutdown -r now
