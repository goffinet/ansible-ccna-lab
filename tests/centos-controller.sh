#!/bin/bash

if [ ! -f /etc/redhat-release ] ; then echo Please with RedHat Linux ; exit ; fi
hostnamectl set-hostname controller
yum -y remove ansible
yum -y install python3-pip git sshpass
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
sed -i 's/^#\$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
sed -i 's/^#\$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf
sed -i 's/^#\$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf
sed -i 's/^#\$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf
systemctl restart rsyslog
firewall-cmd --permanent --add-service dhcp
firewall-cmd --permanent --add-service dns
firewall-cmd --permanent --add-service syslog
firewall-cmd --reload
git clone https://github.com/goffinet/ansible-ccna-lab
python3 -m pip install pip --upgrade
python3 -m pip install ansible
python3 -m pip install paramiko
python3 -m pip install ansible-lint
python3 -m pip install netaddr
python3 -m pip install ansible-cmdb
source /etc/os-release
yum -y install git autoconf automake libtool make readline-devel texinfo net-snmp-devel groff pkgconfig json-c-devel pam-devel bison flex pytest c-ares-devel python-devel python-sphinx libcap-devel elfutils-libelf-devel libunwind-devel protobuf-c-devel
yum -y install https://rpm.frrouting.org/repo/frr-stable-repo-1-0.el${VERSION_ID}.noarch.rpm
yum -y install frr frr-pythontools
#cat << EOF > /etc/frr/eigrpd.conf
#router eigrp 1
# network 11.12.13.0/24
#EOF
#chown frr:frr /etc/frr/eigrpd.conf
#chmod 640 /etc/frr/eigrpd.conf
gpasswd -a frr frrvty
#sed -i 's/eigrpd=.*/eigrpd=yes/g' /etc/frr/daemons
systemctl enable frr
systemctl start frr
#vtysh -f /etc/frr/eigrpd.conf
