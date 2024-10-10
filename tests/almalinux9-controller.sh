#!/bin/bash

echo "start: $(date)" >> /root/setup.log
hostnamectl set-hostname controller
echo -e "[main]\ndns=none" > /etc/NetworkManager/conf.d/90-dns-none.conf
systemctl reload NetworkManager
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
chattr +i /etc/resolv.conf
dnf -y install dnsmasq
systemctl enable dnsmasq
cat << EOF > /etc/dnsmasq.conf
interface=lo0
interface=eth0
dhcp-range=11.12.13.100,11.12.13.150,255.255.255.0,512h
dhcp-option=3
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
systemctl start dnsmasq
echo "end: $(date)" >> /root/setup.log
