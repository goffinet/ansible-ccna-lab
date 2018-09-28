# Ansible CCNA Tripod

## 1. Mise en place minimale

On utilise des IOSv pour les routeurs L3 avec 8 interfaces GigabitEthernet.

L'interface `GigabitEthernet 0/7` sert de console de contrôle TCP/IP et ne participe pas au routage.

## 2. Topologie de base

Topologie

![](https://www.lucidchart.com/publicSegments/view/3328e715-30bf-48a8-a48d-1ff276420520/image.png)

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


## 3. Prérequis SSH sur les noeuds Cisco IOS

```
hostname R1
int g0/7
 ip add dhcp
 no shut
ip domain-name lan
username root privilege 15 password testtest
ip ssh version 2
ip scp server enable
crypto key generate rsa modulus 2048
line vty 0 4
 login local
 transport input ssh
end
wr

```

