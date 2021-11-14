#!/bin/bash

echo "start: $(date)" >> /root/setup.log
hostnamectl set-hostname controller
systemctl disable systemd-resolved
systemctl stop systemd-resolved
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
chattr +i /etc/resolv.conf
yum -y install dnsmasq
systemctl enable dnsmasq
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
sed -i 's/^#\$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
sed -i 's/^#\$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf
sed -i 's/^#\$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf
sed -i 's/^#\$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf
systemctl restart rsyslog
firewall-cmd --permanent --add-service dhcp
firewall-cmd --permanent --add-service dns
firewall-cmd --permanent --add-service syslog
firewall-cmd --reload
yum -y install python3-pip sshpass python3-paramiko python3-netaddr python3-ansible-lint ansible git
git clone https://github.com/goffinet/ansible-ccna-lab
echo "end: $(date)" >> /root/setup.log
