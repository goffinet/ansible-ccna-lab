#!/bin/bash

hostnamectl set-hostname controller
yum -y install python3-pip git sshpass python3-paramiko python3-netaddr python3-ansible-lint ansible git dnsmasq
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
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
chattr +i /etc/resolv.conf
systemctl enable dnsmasq
sed -i 's/^#\$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
sed -i 's/^#\$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf
sed -i 's/^#\$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf
sed -i 's/^#\$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf
firewall-cmd --permanent --add-service dhcp
firewall-cmd --permanent --add-service dns
firewall-cmd --permanent --add-service syslog
firewall-cmd --reload
