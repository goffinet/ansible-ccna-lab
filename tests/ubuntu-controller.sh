!#/bin/bash

hostnamectl set-hostname controller
apt-get update && apt-get -y install python3-pip
pip3 install ansible
pip3 install paramiko
pip3 install ansible-lint
pip3 install netaddr
systemctl disable systemd-resolved
systemctl stop systemd-resolved
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
apt -y install git dnsmasq
cat << EOF > /etc/dnsmasq.conf
interface=lo0
interface=eth0
dhcp-range=11.12.13.100,11.12.13.150,255.255.255.0,512h
dhcp-option=3
EOF
cat << EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 11.12.13.1/24
      nameservers:
          addresses: [127.0.0.1, 1.1.1.1]
    eth1:
      dhcp4: yes
EOF
netplan apply
systemctl restart dnsmasq
systemctl enable dnsmasq
