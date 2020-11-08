---
layout: single
title: "Les topologies CCNA"
permalink: /topologies-ccna/
excerpt: " "
tags:
  - tutoriel
sidebar:
  nav: "menu"
date: 2020-05-24
---

Les topologies réseau développées sont décrites dans différents inventaires et se configurent avec un livre de jeu du même nom :

- "gateway" : un seul routeur connecte l'Internet et offre des services au LAN comme serveurs DHCP et RDNSS
- "bipod" : topologie d'interconnexion de deux LANs distants
- "tripod" : topologie de base maillée à trois routeurs avec un accès à l'Internet
- "router_on_a_stick" : topologie d'apprentissage des VLANs
- "switchblock" : topologie de commutateurs de couche Access et Distribution redondants
- "ccna" : topologies "tripod" et "switchblock" connectées entre elles
- "networking-workshop" : exercice tiers

## 4.1. Topologie CCNA Gateway

Un seul routeur Cisco qui connecte l'Internet et qui offre des services au LAN comme serveurs DHCP et RDNSS.

![](../assets/images/gateway_lab.png)

Références :

* [Lab passerelle Internet](https://cisco.goffinet.org/ccna/services-infrastructure/lab-passerelle-internet/)

![Topologie CCNA Gateway](https://www.lucidchart.com/publicSegments/view/d8a42bbc-5192-48b9-a630-2e968dcf6f43/image.png)

Diagramme : Topologie CCNA Gateway

## 4.2. Topologie CCNA Bipod

Connexion point-à-point entre les deux routeurs R1 et R2.

![Topologie Bipod](https://www.lucidchart.com/publicSegments/view/46f2b887-0e06-40e6-b45c-b07f449adf08/image.png)

Références :

* [Lab routage statique simple](https://cisco.goffinet.org/ccna/routage/lab-routage-statique-simple/)
* [Lab routage RIPv2 simple](https://cisco.goffinet.org/ccnp/rip/lab-ripv2-simple/)
* [Lab Routage OSPF simple](https://cisco.goffinet.org/ccna/ospf/lab-routage-ospf-simple/)
* [Lab de routage et services IPv4/IPv6](https://cisco.goffinet.org/ccna/services-infrastructure/lab-routage-et-services-ipv4-ipv6/)

Diagramme : Topologie CCNA Bipod

![](../assets/images/bipod_lab.png)

## 4.3. Topologie CCNA Tripod

Cette topologie maillée à trois routeurs peut être désignée par "tripod". Elle est la couche "Core" de la topologie CCNA complète.

![](../assets/images/tripod_lab.png)

### 4.3.1. Topologie logique

![Topologie CCNA Tripod](https://www.lucidchart.com/publicSegments/view/3328e715-30bf-48a8-a48d-1ff276420520/image.png)

### 4.3.2. Brève description

Trois périphériques IOSv interconnectés entre eux :

* R1
* R2
* R3

| Routeur | Interface | Adresse IPv4 | Adresses IPv6 | Description |
| --- | --- | --- | --- | --- |
| R1 | G0/0 | `192.168.1.1/24` | `FE80::1`, `FD00:FD00:FD00:1::1/64` | LAN de R1 |
| R1 | G0/2 | `192.168.225.1/24` | `FE80::1` | Connexion vers R2 |
| R1 | G0/3 | `192.168.226.1/24` | `FE80::1` | Connexion vers R3 |
| R2 | G0/0 | `192.168.33.1/24` | `FE80::2`, `FD00:FD00:FD00:2::1/64` | LAN de R2 |
| R2 | G0/1 | `192.168.225.2/24` | `FE80::2` | Connexion vers R1 |
| R2 | G0/3 | `192.168.227.1/24` | `FE80::2` | Connexion vers R3 |
| R3 | G0/0 | `192.168.65.1/24` | `FE80::3`, `FD00:FD00:FD00:3::1/64` | LAN de R3 |
| R3 | G0/1 | `192.168.226.2/24` | `FE80::3` | Connexion vers R1 |
| R3 | G0/2 | `192.168.227.2/24` | `FE80::3` | Connexion vers R2 |

* On activera un service DHCP sur chaque réseau local (`GigabitEthernet0/0`).
* Le routeur R1 connecte l'Internet. Le service NAT est activé.

On activera les protocoles de routage IPv4 et IPv6 :

* [RIPv2](https://cisco.goffinet.org/categories/rip)
* [OSPFv2 et/ou OSPFv3](https://cisco.goffinet.org/categories/ospf)
* [EIGRP pour IPv4 et/ou IPv6](https://cisco.goffinet.org/categories/eigrp) avec des exemples de variance

Références :

* [Lab routage RIPv2 VLSM](https://cisco.goffinet.org/ccnp/rip/lab-ripv2-vlsm/)
* [Lab Routage EIGRP](https://cisco.goffinet.org/ccnp/eigrp/lab-routage-eigrp/)
* [Lab Routage OSPF Multi-Area](https://cisco.goffinet.org/ccna/ospf/lab-ospf-multi-area/)

## 4.4. Topologie variante Router on a Stick

Variante de la topologie Tripod en utilisant un Trunk Vlan entre R1 et SW0 ainsi qu'entre SW0 et SW1.

![Topologie variante Router on a Stick](https://www.lucidchart.com/publicSegments/view/9414c7ca-8f9a-4306-8908-a1e1c44009e2/image.png)

Diagramme : Topologie variante Router on a Stick

![](../assets/images/router_on_a_stick_lab.png)

Références :

* [Lab VLAN de base](https://cisco.goffinet.org/ccna/vlans/lab-vlan-base-cisco-ios/)

## 4.5. Topologie CCNA Switchblock

Cette seconde topologie "switchblock" met en oeuvre des _commutateurs_. Cette topologie est plus complexe et se connecte à la topologie "tripod". Elle met en oeuvre les couches "distribution" et "access".

![](../assets/images/switchblock_lab.png)

Références :

* [Technologies VLANs](https://cisco.goffinet.org/ccna/vlans/)
* [Redondance de liens](https://cisco.goffinet.org/ccna/redondance-de-liens/)
* [Disponibilité dans le LAN](https://cisco.goffinet.org/ccna/disponibilite-lan/)

### 4.5.1. Topologie avec redondance de passerelle HSRP

![Topologie avec redondance de passerelle HSRP](https://www.lucidchart.com/publicSegments/view/84f170f5-af2b-44c1-8f6d-d169399dbba2/image.png)

### 4.5.2. VLANs

| VLAN | Ports Access (AS1 et AS2) | plage d'adresse | Passerelle par défaut |
| --- | --- | --- | --- |
| VLAN 10 | `g2/0` | `172.16.10.0/24` | **`172.16.10.254`** |
| VLAN 20 | `g2/1` | `172.16.20.0/24` | **`172.16.10.254`** |
| VLAN 30 | `g2/2` | `172.16.30.0/24` | **`172.16.10.254`** |
| VLAN 40 | `g2/3` | `172.16.40.0/24` | **`172.16.10.254`** |
| VLAN 99 | VLAN natif | Management

### 4.5.3. Ports Etherchannel et Trunk VLANs

| PortChannel | ports physiques | Commutateurs |
| --- | --- | ---
| po1 | `g0/0`,`g1/0` | AS1 - DS1 |
| po2 | `g0/1`,`g1/1` | AS1 - DS2 |
| po3 | `g0/2`,`g1/2` | DS1 - DS2 |
| po4 | `g0/0`,`g1/0` | AS2 - DS2 |
| po5 | `g0/1`,`g1/1` | AS2 - DS1 |

### 4.5.4. Spanning-Tree

| VLANs | DS1 | DS2 |
| --- | --- | --- |
| VLANs 1,10,30,99 | `root primary` | `root secondary` |
| VLANs 20,40 | `root secondary` | `root primary` |

### 4.5.5. Plan d'adressage

| Commutateur | Interface | Adresse IPv4 | Adresse(s) IPv6 |
| --- | --- | --- | --- |
| DS1 | VLAN10 | `172.16.10.252/24` | `FD00:1AB:10::1/64` |
| DS1 | VLAN20 | `172.16.20.252/24` | `FD00:1AB:20::1/64` |
| DS1 | VLAN30 | `172.16.30.252/24` | `FD00:1AB:30::1/64` |
| DS1 | VLAN40 | `172.16.40.252/24` | `FD00:1AB:40::1/64` |
| DS2 | VLAN10 | `172.16.10.253/24` | `FD00:1AB:10::2/64` |
| DS2 | VLAN20 | `172.16.20.253/24` | `FD00:1AB:20::2/64` |
| DS2 | VLAN30 | `172.16.30.253/24` | `FD00:1AB:30::2/64` |
| DS2 | VLAN40 | `172.16.40.253/24` | `FD00:1AB:40::2/64` |

### 4.5.6. HSRP

| Commutateur | Interface | Adresse IPv4 virtuelle | Adresse IPv6 virtuelle | Group | Priorité |
| --- | --- | --- | --- | --- | --- |
| DS1 | VLAN10 | `172.16.10.254/24` | `FE80::d:1/64` | 10/16 | 150, prempt |
| DS1 | VLAN20 | `172.16.20.254/24` | `FE80::d:1/64` | 20/26 | default |
| DS1 | VLAN30 | `172.16.30.254/24` | `FE80::d:1/64` | 30/36 | 150, prempt |
| DS1 | VLAN40 | `172.16.40.254/24` | `FE80::d:1/64` | 40/46 | default |
| DS2 | VLAN10 | `172.16.10.254/24` | `FE80::d:2/64` | 10/16 | default |
| DS2 | VLAN20 | `172.16.20.254/24` | `FE80::d:2/64` | 20/26 | 150, prempt |
| DS2 | VLAN30 | `172.16.30.254/24` | `FE80::d:2/64` | 30/36 | default |
| DS2 | VLAN40 | `172.16.40.254/24` | `FE80::d:2/64` | 40/46 | 150, prempt |

### 4.5.7. Ressources requises

*	4 commutateurs (vios_l2 Software (vios_l2-ADVENTERPRISEK9-M), Experimental Version 15.2(20170321:233949))
*	8 PCs (Centos 7 KVM ou Ubuntu Docker)
*	(Câbles de console pour configurer les périphériques Cisco IOS via les ports de console)
*	Câbles Ethernet conformément à la topologie

### 4.5.8. Explication

Dans l'exercice de laboratoire "Lab répartition de charge avec Rapid Spanning-Tree", nous avons appris à déployer Rapid Spanning-Tree entre la couche Distribution et la couche Access. Il manque manifestement une sûreté au niveau de la passerelle par défaut que constitue le commutateur de Distribution. Afin d'éviter ce point unique de rupture, on apprendra à configurer et vérifier HSRP. Dans cette topologie une passerelle devient routeur "Active" pour certains VLANs et reste en HSRP "Standby" pour d'autres VLANs et inversément.

On trouvera plus bas les fichiers de configuration qui déploient la solution  VLANs, Trunking, Etherchannel, Rapid Spanning-Tree, SVI IPv4 et IPv6 et DHCP. Par rapport à l'exercice de laboratoire "Lab répartition de charge avec Rapid Spanning-Tree", tout reste identique sauf le paramètre de passerelle.

## 4.6. Toplogie CCNA Tripod et Switchblock

Cette topologie interconnecte les topologies "tripod" et "switchblock".

![](https://www.lucidchart.com/publicSegments/view/aacc6247-aa9a-44b2-a1ba-43ccb81deab7/image.png)

Avec le contrôleur :

![](../assets/images/ccna_lab_control.png)

## 4.7. Topologie Ansible Networking Workshop

Cette topologie s'utilise dans le cadre de l'exercice [ANSIBLE RÉSEAU](https://iac.goffinet.org/ansible-network/) avec le projet [Ansible Networking Workshop Files](https://github.com/goffinet/networking-workshop).

<!--

![Ansible Networking Workshop](https://github.com/network-automation/linklight/raw/master/images/network_diagram.png)

-->

![](../assets/images/networking-workshop_lab.png)
