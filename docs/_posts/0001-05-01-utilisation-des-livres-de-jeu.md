---
layout: single
title: "L'utilisation des livres de jeu"
permalink: /utilisation-des-livres-de-jeu/
excerpt: " "
tags:
  - tutoriel
sidebar:
  nav: "menu"
date: 2020-05-24
---

Le serveur et le projet GNS3 sont lancés et tous les périphériques de la topologie ont démarré. A partir de la station de contrôle, veuillez vous rendre dans le dossier des livres de jeu `ansible-ccna-lab/playbooks/` :

```bash
cd
git clone https://github.com/goffinet/ansible-ccna-lab
cd ansible-ccna-lab/playbooks
```

## 5.1. Inventaire et variables d'inventaire du livre de jeu ccna.yml

L'inventaire par défaut est défini comme suit (fichier `inventories/ccna/hosts`) et correspond à la topologie ccna (tripod + switchblock) :

```ini
[all:vars]
#method=modules # modules or templating not yet implemented

[core]
R1
R2
R3

[distribution]
DS1
DS2

[access]
AS1
AS2

[blocks:children]
distribution
access

[routers:children]
core

[switches:children]
blocks

[cisco:children]
core
blocks

[core:vars]
mgmt_interface=GigabitEthernet0/7
image_style=iosv_l3

[blocks:vars]
mgmt_interface=GigabitEthernet3/3
image_style=iosv_l2

[cisco:vars]
ansible_user=root
ansible_ssh_pass=testtest
ansible_port=22
ansible_connection=ansible.netcommon.network_cli
ansible_network_os=cisco.ios.ios

```

La variable `ansible_network_os=cisco.ios.ios` conditionne l'exécution des rôles du livre de jeu.

Les paramètres de configuration sont définis en YAML dans les fichiers de variables d'inventaire (fichier au nom du groupe dans le dossier `inventories/ccna/group_vars` et fichier au nom de l'hôte dans le dossier `inventories/ccna/host_vars`).

```
inventories/ccna
├── group_vars
│   ├── all       --> protocoles de routage ipv4/ipv6
│   ├── blocks    --> variables vlans, switchports et stp mode
│   └── core      --> variables routage, rdnss
├── hosts         --> fichier d'inventaire, avec des variables génériques
└── host_vars     --> variables propres à chaque périphérique
    ├── AS1
    ├── AS2
    ├── DS1
    ├── DS2
    ├── R1
    ├── R2
    └── R3
```

On rapellera que le modèle de données utilisé est purement arbitraire. Une modification du modèle de données aura probablement des conséquences sur l'éxécution de certaines tâches utilisée dans les livres de jeu.

## 5.2. Livres de jeu

Quels sont les livres de jeu disponibles ? Les livres de jeu (`playbooks/`) font appel à des rôles qui trouvent la valeur des variables dans l'inventaire.

Le livre de jeu `tripod.yml` configure la topologie tripod :

```bash
ansible-playbook tripod.yml -v
```

Le livre de jeu `blocks.yml` configure la topologie switchblock :

```bash
ansible-playbook switchblock.yml -v
```

Le livre de jeu `ccna.yml` configure l'ensemble :

```bash
ansible-playbook ccna.yml -v
```

## 5.3. Les rôles invoqués

On prendra l'exemple du livre de jeu `bipod.yaml` qui fait appel à une série de rôles dans un ordre précis. Le nom des rôles semblerait suffisament explicite pour toute personne disposant d'un niveau CCNA.

```yaml
---
# bipod.yml
- hosts: core
  gather_facts: False
  roles:
    - role: ios_common
    - role: ios_interface
    - role: ios_ipv4
    - role: ios_ipv6
    - role: ios_ipv4-routing
    - role: ios_ipv6-routing
    - role: ios_static-routing
    - role: ios_rip
      when: '"rip" in ipv4.routing'
    - role: ios_recursive-dns-server
    - role: ios_dhcp-server
    - role: ios_nat44
    - role: ios_write
```

Ces rôles trouvent leur place dans le dossier `roles` du projet :

```
roles/
├── ios_common/
├── ios_dhcp-server/
├── ios_disable-dynamic-ipv4-routing/
├── ios_eigrp4/
├── ios_eigrp6/
├── ios_etherchannel/
├── ios_fhrp/
├── ios_interface
├── ios_ipv4/
├── ios_ipv4-routing/
├── ios_ipv6/
├── ios_ipv6-routing/
├── ios_nat44/
├── ios_no-ipv4-routing
├── ios_ospfv2/
├── ios_ospfv3/
├── ios_recursive-dns-server/
├── ios_rip/
├── ios_spanning-tree/
├── ios_static-routing/
├── ios_vlans/
└── ios_write/
```

## 5.4. Diagnostic de base

_à améliorer_

<!--

Diagnostic du routage sur R1 :

```bash
ansible R1 -m ios_command -a "commands='show ip route'"
```

Diagnostic à partir des routeurs Core :

```bash
ansible core -m ios_command -a "commands='traceroute 192.168.1.1 source GigabitEthernet0/0 probe 1 numeric'"
```

```bash
ansible core -m ios_command -a "commands='traceroute 172.16.10.1 source GigabitEthernet0/0 probe 1 numeric'"
```

-->

## 5.5. Remettre à zéro les configurations

Le livre de jeu [playbooks/restore_config.yml](https://github.com/goffinet/ansible-ccna-lab/blob/master/playbooks/restore_config.yml) restaure des configurations vierges sur les hôtes d'inventaire Cisco.
