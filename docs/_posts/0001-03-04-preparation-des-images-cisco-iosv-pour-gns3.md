---
layout: single
title: "Préparation des images Cisco IOSv pour GNS3"
permalink: /mise-en-place-du-lab-sur-gns3/preparation-des-images-cisco-iosv-pour-gns3/
excerpt: " "
tags:
  - tutoriel
sidebar:
  nav: "menu"
date: 2020-05-24
---

Si vous avez utilisé le livre de jeu [`lab_setup.yml`](https://github.com/goffinet/ansible-ccna-lab/blob/master/playbooks/lab_setup.yml), cette étape est purement informative.

Les livres de jeu sont testés avec [GNS3 Server](https://cisco.goffinet.org/ccna/cisco-ios-cli/installer-et-configurer-gns3/) et Qemu/KVM sous Linux.

Il y a trois types de périphériques utilisés dans les topologies.

| Périphériques | Images Qemu/KVM | Commentaire |
| --- | --- | --- |
| Routeur Cisco IOSv | `vios-adventerprisek9-m.vmdk.SPA.156-2.T` ou `vios-adventerprisek9-m.vmdk.SPA.157-3.M3` avec `IOSv_startup_config.img`  | [VIRL](https://learningnetworkstore.cisco.com/virtual-internet-routing-lab-virl/cisco-personal-edition-pe-20-nodes-virl-20) |
| Commutateur Cisco IOSv L2/L3  | `vios_l2-adventerprisek9-m.03.2017.qcow2` ou `vios_l2-adventerprisek9-m.SSA.high_iron_20180619.qcow2`  |  [VIRL](https://learningnetworkstore.cisco.com/virtual-internet-routing-lab-virl/cisco-personal-edition-pe-20-nodes-virl-20) |
| Poste de travail L2 à L7, Station de contrôle  | [`centos7.qcow2`](http://get.goffinet.org/kvm/centos7.qcow2)  |  Le [fichier d'appliance GNS3](http://get.goffinet.org/gns3a/centos7.gns3a) ou Docker ou VPCS |

Les livres de jeu peuvent vérifier la nature du périphérique utilisé de type Cisco et de type routeur ou commutateur à partir de variables d'inventaire.

Il sera nécessaire d'activer SSH sur les périphériques à des fins de gestionn par Ansible. On trouvera un modèle jinja2 dans le fichier [`playbooks/templates/iosv_default_config.j2`](ttps://github.com/goffinet/ansible-ccna-lab/blob/master/playbooks/templates/iosv_default_config.j2).

## 3.3.1. Les Routeurs IOSv

On utilise des images IOSv `vios-adventerprisek9-m.vmdk.SPA.156-2.T` pour les routeurs L3 avec 8 interfaces GigabitEthernet.

L'interface `GigabitEthernet0/7` sert de console de contrôle TCP/IP et ne participe pas au routage.

SSH est activé de la manière suivante, sur R1 par exemple :

```shell
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

## 3.3.2. Commutateurs IOSv

On utilise des images IOSv-L2 `vios_l2-adventerprisek9-m.03.2017.qcow2` pour les commutateurs multicouches.

L'interface `GigabitEthernet3/3` sert de console de contrôle TCP/IP et ne participe pas au routage.

SSH est activé de la manière suivante, sur AS1 par exemple :

```shell
hostname AS1
int GigabitEthernet3/3
 no switchport
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
