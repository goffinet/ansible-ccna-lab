# Ansible CCNA lab

## 1. Mise en place minimale

### Images GNS3

* image IOSv (kvm)
* image IOSv-L2 (kvm)
* image Centos (kvm)

### Routeurs

On utilise des IOSv pour les routeurs L3 avec 8 interfaces GigabitEthernet.

L'interface `GigabitEthernet0/7` sert de console de contrôle TCP/IP et ne participe pas au routage.

SSH est activé de la manière suivante, sur R1 par exemple :

```
hostname R1
int GigabitEthernet0/7
 ip address dhcp
 no shutdown
 no cdp enable
ip domain-name lan
username root privilege 15 password testtest
crypto key generate rsa modulus 2048
ip ssh version 2
ip scp server enable
line vty 0 4
 login local
 transport input ssh
end
wr

```

### Commutateurs

On utilise des IOSv-L2 pour les commutateurs multicouches.

L'interface `GigabitEthernet3/3` sert de console de contrôle TCP/IP et ne participe pas au routage.

SSH est activé de la manière suivante, sur AS1 par exemple :

```
hostname AS1
int GigabitEthernet3/3
 ip address dhcp
 no shutdown
 no cdp enable
ip domain-name lan
username root privilege 15 password testtest
crypto key generate rsa modulus 2048
ip ssh version 2
ip scp server enable
line vty 0 4
 login local
 transport input ssh
end
wr

```

### Station de contrôle

La station de contrôle connecte tous les périphériques en SSH.

Elle offre un service DHCP avec enregistrement dynamique des noms d'hôte dans un serveur DNS (dnsmasq).

Le logiciel Ansible est fraîchement installé.

```
yum -y install dnsmasq
yum -y install ansible git dnsmasq
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
systemctl enable dnsmasq
hostnamectl set-hostname controller
shutdown -r now

```

Il est nécessaire de cloner sur la machine de contrôle de dépot.

```
git clone https://github.com/goffinet/ansible-ccna-lab
```


## 2. Topologie tripod

### Topologie logique

![Topologie Tripod](https://www.lucidchart.com/publicSegments/view/3328e715-30bf-48a8-a48d-1ff276420520/image.png)

### Topologie GNS3

[Topologie GNS3](/#todo).

### Brève description

Trois périphériques IOSv interconnectés entre eux :

* R1
* R2
* R3

Routeur | Interface | Adresse IPv4 | Adresses IPv6 | Description
--- | --- | --- | --- | ---
R1 | G0/0 | 192.168.X.1/24 | fe80::1, fd00:fd00:fd00:1::1/64 | LAN de R1
R1 | G0/2 | 192.168.225.1/24 | fe80::1 | Connexion vers R2
R1 | G0/3 | 192.168.227.1/24 | fe80::1 | Connexion vers R3
R2 | G0/0 | 192.168.33.1/24 | fe80::2, fd00:fd00:fd00:2::1/64 | LAN de R2
R2 | G0/1 | 192.168.225.2/24 | fe80::2 | Connexion vers R1
R2 | G0/3 | 192.168.226.1/24 | fe80::2 | Connexion vers R3
R3 | G0/0 | 192.168.65.1/24 | fe80::3, fd00:fd00:fd00:3::1/64 | LAN de R3
R3 | G0/1 | 192.168.227.2/24 | fe80::3 | Connexion vers R1
R3 | G0/2 | 192.168.226.2/24 | fe80::3 | Connexion vers R2

* On activera un service DHCP sur chaque réseau local (`GigabitEthernet0/0`).
* Le routeur R1 connecte l'Internet. Le service NAT est activé.





## Topologie Switchblock

## Toplogie CCNA R&S

![](https://www.lucidchart.com/publicSegments/view/aacc6247-aa9a-44b2-a1ba-43ccb81deab7/image.png)


## Utilisation

```
cd ansible-ccna-lab
```

Note :

```
ansible all -m ping
```

Pour déployer la topologie tripod soit le playbook `core.yml`.

Pour déployer la topologie switchblock soit le playbook `blocks.yml`

Pour déployer le couche core et le switchblock soit le playbook `site.yml`


Note : Diagnostic du routage sur R1

```
ansible R1 -m ios_command -a "commands='show ip route'"
```

Notes :

```
ansible core -m ios_command -a "commands='traceroute 192.168.1.1 source GigabitEthernet0/0 probe 1 numeric'"
```
```
ansible core -m ios_command -a "commands='traceroute 172.16.10.1 source GigabitEthernet0/0 probe 1 numeric'"
```



## Rôles / Tags

* l2
* full-ipv4
* full-ipv6
* ipv4
* ipv6
* etherchannel
* vlan
* eigrp4
* eigrp6
* ospfv2
* ospfv3
* fhrp4
* fhrp6
* dhcp-server
* rdnss
* syslog
* ntp
* snmpv2c
* snmpv3
* zbf
* dhcp-relay
* ra-config
* dhcpv6 stateless
* dhcpv6 stateful
* save
* write

## Historical Todo

### Phase 0 : Écriture de playbooks avec les modules ios_*

Archivé.

### Phase I

Portage en rôles.

* Revoir la structure des données
* ~~dependencies~~
* ~~tags**~~
* tasks by jinja2 templating
* **fhrp4**
* **fhrp6**
* **rdnss**
* **syslog**
* dhcp-relay
* **ntp** (authentification)
* auth eigrp4/6 ospfv2/v3
* **snmpv2c** / snmpv3
* **zbf**
* ra-config / dhcpv6 stateless / dhcpv6 stateful + (dns)

### Phase II

Infrastructure immutable

Immutable roles by templating one config file  based on infrastructure choices (variables) and pushed by `config replace flash:XXX force` procedure to the devices.

### Phase III

* Reporting
* PPPoE, BGP, GRE IPv4, GRE IPv6, Firewall
