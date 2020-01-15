# Ansible CCNA lab

- [1. Mise en place minimale](#1-mise-en-place-minimale)
  - [1.1. Images GNS3](#11-images-gns3)
  - [1.2. Routeurs](#12-routeurs)
  - [1.3. Commutateurs](#13-commutateurs)
  - [1.4. Station de contrôle](#14-station-de-contrle)
  - [1.5. Cloner le dépôt](#15-cloner-le-dpt)
  - [1.6. Examiner les paramètres de configuration de Ansible](#16-examiner-les-paramtres-de-configuration-de-ansible)
- [2. Topologie CCNA tripod](#2-topologie-ccna-tripod)
  - [2.1. Topologie logique](#21-topologie-logique)
  - [2.2. Brève description](#22-brve-description)
  - [2.3. Variante Standalone](#23-variante-standalone)
  - [2.4. Variante Site to Site](#24-variante-site-to-site)
  - [2.5. Variante Router on a Stick](#25-variante-router-on-a-stick)
- [3. Topologie CCNA Switchblock](#3-topologie-ccna-switchblock)
  - [3.1. Topologie avec redondance de passerelle HSRP](#31-topologie-avec-redondance-de-passerelle-hsrp)
  - [3.2. VLANs](#32-vlans)
  - [3.3. Ports Etherchannel et Trunk VLANs](#33-ports-etherchannel-et-trunk-vlans)
  - [3.4. Spanning-Tree](#34-spanning-tree)
  - [3.5.Plan d'adressage](#35plan-dadressage)
  - [3.6. HSRP](#36-hsrp)
  - [3.7. Ressources requises](#37-ressources-requises)
  - [3.8. Explication](#38-explication)
- [4. Toplogie CCNA Core et Switchblock](#4-toplogie-ccna-core-et-switchblock)
- [5. Utilisation](#5-utilisation)
  - [5.1. Inventaire et variables d'inventaire du livre de jeu ccna.yml](#51-inventaire-et-variables-dinventaire-du-livre-de-jeu-ccnayml)
  - [5.2. Livres de jeu](#52-livres-de-jeu)
  - [5.3. Diagnostic de base](#53-diagnostic-de-base)
- [Notes](#notes)
  - [Phase I](#phase-i)
  - [Comment rendre une tâche ios_config idempotente ?](#comment-rendre-une-tche-iosconfig-idempotente-)
  - [Phase II](#phase-ii)
  - [Phase III](#phase-iii)

On trouvera ici un livre de jeu inspiré des topologies et des sujets du Cisco CCNA et plus.

Il est basé sur trois éléments : des livres de jeu qui peuvent en appeler d'autres nommés selon la **topologie** ; ces livres de jeu configurent des hôtes d'inventaire avec des tâches organisées en **rôles** ; les paramètres de la topologie sont configurés en tant que **variables d'inventaire selon un certain modèle de données**.

Les topologies sont organisées de la manière suivante :

```yaml
ccna:
  tripod:
    standalone:
    site_to_site:
    router_on_stick:
  switchblock:
```

## 1. Mise en place minimale

Pour les utilisateur de la topologie GNS3 fournie en classe, sur tous les périphériques, il sera peut-être nécessaire de regénérer les clés RSA des périphériques Cisco :

```raw
enable
configure terminal
crypto key generate rsa modulus 2048
exit
wr

```

### 1.1. Images GNS3

Les livres de jeux sont testés avec [GNS3 Server](https://cisco.goffinet.org/ccna/cisco-ios-cli/installer-et-configurer-gns3/) et Qemu/KVM sous Linux.

Périphériques | Images Qemu/KVM | Commentaire
---|---|---
Routeur Cisco IOSv 15.6(2)T | `vios-adventerprisek9-m.vmdk.SPA.156-2.T` avec `IOSv_startup_config.img`  | [VIRL 1.3.296 (Aug. 2017 Release)](https://learningnetwork.cisco.com/docs/DOC-33132)
Commutateur Cisco IOSv L2/L3  | `vios_l2-adventerprisek9-m.03.2017.qcow2`  | [VIRL 1.3.296 (Aug. 2017 Release)](https://learningnetwork.cisco.com/docs/DOC-33132)
Poste de travail L2 à L7, Station de contrôle  | [`centos7.qcow2`](http://get.goffinet.org/kvm/centos7.qcow2)  |  Le [fichier d'appliance GNS3](http://get.goffinet.org/gns3a/centos7.gns3a)

### 1.2. Routeurs

On utilise des images IOSv pour les routeurs L3 avec 8 interfaces GigabitEthernet.

L'interface `GigabitEthernet0/7` sert de console de contrôle TCP/IP et ne participe pas au routage.

SSH est activé de la manière suivante, sur R1 par exemple :

```raw
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

### 1.3. Commutateurs

On utilise des images IOSv-L2 pour les commutateurs multicouches.

L'interface `GigabitEthernet3/3` sert de console de contrôle TCP/IP et ne participe pas au routage.

SSH est activé de la manière suivante, sur AS1 par exemple :

```raw
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

### 1.4. Station de contrôle

La station de contrôle connecte tous les périphériques en SSH.

Elle offre un service DHCP avec enregistrement dynamique des noms d'hôte dans un serveur DNS (dnsmasq).

Le logiciel Ansible est fraîchement installé.

```bash
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

### 1.5. Cloner le dépôt

Il est nécessaire de cloner le dépot sur la machine de contrôle.

```bash
git clone https://github.com/goffinet/ansible-ccna-lab
cd ansible-ccna-lab
```

### 1.6. Examiner les paramètres de configuration de Ansible

Le fichier de configuration `ansible.cfg`dans le dossier du dépôt configure Ansible :

```ini
[defaults]
inventory = ./inventories/ccna/hosts
roles_path = ~/.ansible/roles:./roles
host_key_checking = False
retry_files_enabled = False
log_path = ./ansible.log
#forks = 20
strategy = linear
#gathering = explicit
#display_ok_hosts=no
#display_skipped_hosts=no
callback_whitelist = profile_tasks
[callback_profile_tasks ]
task_output_limit = 100
```

## 2. Topologie CCNA tripod

Cette topologie maillée à trois routeurs peut être désignée par "tripod".

### 2.1. Topologie logique

![Topologie Tripod](https://www.lucidchart.com/publicSegments/view/3328e715-30bf-48a8-a48d-1ff276420520/image.png)

### 2.2. Brève description

Trois périphériques IOSv interconnectés entre eux :

* R1
* R2
* R3

Routeur | Interface | Adresse IPv4 | Adresses IPv6 | Description
--- | --- | --- | --- | ---
R1 | G0/0 | `192.168.1.1/24` | `fe80::1`, `fd00:fd00:fd00:1::1/64` | LAN de R1
R1 | G0/2 | `192.168.225.1/24` | `fe80::1` | Connexion vers R2
R1 | G0/3 | `192.168.227.1/24` | `fe80::1` | Connexion vers R3
R2 | G0/0 | `192.168.33.1/24` | `fe80::2`, `fd00:fd00:fd00:2::1/64` | LAN de R2
R2 | G0/1 | `192.168.225.2/24` | `fe80::2` | Connexion vers R1
R2 | G0/3 | `192.168.226.1/24` | `fe80::2` | Connexion vers R3
R3 | G0/0 | `192.168.65.1/24` | `fe80::3`, `fd00:fd00:fd00:3::1/64` | LAN de R3
R3 | G0/1 | `192.168.227.2/24` | `fe80::3` | Connexion vers R1
R3 | G0/2 | `192.168.226.2/24` | `fe80::3` | Connexion vers R2

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

### 2.3. Variante Standalone

Références :

* [Lab Configuration d’un routeur Cisco](https://cisco.goffinet.org/ccna/routage/lab-configuration-routeur-cisco/)

### 2.4. Variante Site to Site

Variante de la topologie Tripod avec une connexion point-à-point entre R1 et R2.

Références :

* [Lab routage statique simple](https://cisco.goffinet.org/ccna/routage/lab-routage-statique-simple/)
* [Lab routage RIPv2 simple](https://cisco.goffinet.org/ccnp/rip/lab-ripv2-simple/)
* [Lab Routage OSPF simple](https://cisco.goffinet.org/ccna/ospf/lab-routage-ospf-simple/)

### 2.5. Variante Router on a Stick

Variante de la topologie Tripod en utilisant un Trunk Vlan entre R1 et SW0 ainsi qu'entre SW0 et SW1.

Références :

* [Lab VLAN de base](https://cisco.goffinet.org/ccna/vlans/lab-vlan-base-cisco-ios/)

## 3. Topologie CCNA Switchblock

Références :

* [Technologies VLANs](https://cisco.goffinet.org/ccna/vlans/)
* [Redondance de liens](https://cisco.goffinet.org/ccna/redondance-de-liens/)
* [Disponibilité dans le LAN](https://cisco.goffinet.org/ccna/disponibilite-lan/)

### 3.1. Topologie avec redondance de passerelle HSRP

![Topologie avec redondance de passerelle HSRP](https://www.lucidchart.com/publicSegments/view/84f170f5-af2b-44c1-8f6d-d169399dbba2/image.png)


### 3.2. VLANs

VLAN | Ports Access (AS1 et AS2) | plage d'adresse | Passerelle par défaut
--- | --- | --- | ---
VLAN 10 | `g2/0` | `172.16.10.0/24` | **`172.16.10.254`**
VLAN 20 | `g2/1` | `172.16.20.0/24` | **`172.16.10.254`**
VLAN 30 | `g2/2` | `172.16.30.0/24` | **`172.16.10.254`**
VLAN 40 | `g2/3` | `172.16.40.0/24` | **`172.16.10.254`**
VLAN 99 | VLAN natif | Management

### 3.3. Ports Etherchannel et Trunk VLANs

PortChannel | ports physiques | Commutateurs
--- | --- | ---
po1 | `g0/0`,`g1/0` | AS1 - DS1
po2 | `g0/1`,`g1/1` | AS1 - DS2
po3 | `g0/2`,`g1/2` | DS1 - DS2
po4 | `g0/0`,`g1/0` | AS2 - DS2
po5 | `g0/1`,`g1/1` | AS2 - DS1

### 3.4. Spanning-Tree

VLANs | DS1 | DS2
--- | --- | ---
VLANs 1,10,30,99 | `root primary` | `root secondary`
VLANs 20,40 | `root secondary` | `root primary`

### 3.5.Plan d'adressage

Commutateur | Interface | Adresse IPv4 | Adresse(s) IPv6
--- | --- | --- | ---
DS1 | VLAN10 | `172.16.10.252/24` | `fd00:1ab:10::1/64`
DS1 | VLAN20 | `172.16.20.252/24` | `fd00:1ab:20::1/64`
DS1 | VLAN30 | `172.16.30.252/24` | `fd00:1ab:30::1/64`
DS1 | VLAN40 | `172.16.40.252/24` | `fd00:1ab:40::1/64`
DS2 | VLAN10 | `172.16.10.253/24` | `fd00:1ab:10::2/64`
DS2 | VLAN20 | `172.16.20.253/24` | `fd00:1ab:20::2/64`
DS2 | VLAN30 | `172.16.30.253/24` | `fd00:1ab:30::2/64`
DS2 | VLAN40 | `172.16.40.253/24` | `fd00:1ab:40::2/64`

### 3.6. HSRP

Commutateur | Interface | Adresse IPv4 virtuelle | Adresse IPv6 virtuelle | Group | Priorité
--- | --- | --- | --- | --- | ---
DS1 | VLAN10 | `172.16.10.254/24` | `fe80::d:1/64` | 10/16 | 150, prempt
DS1 | VLAN20 | `172.16.20.254/24` | `fe80::d:1/64` | 20/26 | default
DS1 | VLAN30 | `172.16.30.254/24` | `fe80::d:1/64` | 30/36 | 150, prempt
DS1 | VLAN40 | `172.16.40.254/24` | `fe80::d:1/64` | 40/46 | default
DS2 | VLAN10 | `172.16.10.254/24` | `fe80::d:2/64` | 10/16 | default
DS2 | VLAN20 | `172.16.20.254/24` | `fe80::d:2/64` | 20/26 | 150, prempt
DS2 | VLAN30 | `172.16.30.254/24` | `fe80::d:2/64` | 30/36 | default
DS2 | VLAN40 | `172.16.40.254/24` | `fe80::d:2/64` | 40/46 | 150, prempt

### 3.7. Ressources requises

*	4 commutateurs (vios_l2 Software (vios_l2-ADVENTERPRISEK9-M), Experimental Version 15.2(20170321:233949))
*	8 PCs (Centos 7 KVM ou Ubuntu Docker)
*	(Câbles de console pour configurer les périphériques Cisco IOS via les ports de console)
*	Câbles Ethernet conformément à la topologie

### 3.8. Explication

Dans l'exercice de laboratoire "Lab répartition de charge avec Rapid Spanning-Tree", nous avons appris à déployer Rapid Spanning-Tree entre la couche Distribution et la couche Access. Il manque manifestement une sûreté au niveau de la passerelle par défaut que constitue le commutateur de Distribution. Afin d'éviter ce point unique de rupture, on apprendra à configurer et vérifier HSRP. Dans cette topologie une passerelle devient routeur "Active" pour certains VLANs et reste en HSRP "Standby" pour d'autres VLANs et inversément.

On trouvera plus bas les fichiers de configuration qui déploient la solution  VLANs, Trunking, Etherchannel, Rapid Spanning-Tree, SVI IPv4 et IPv6 et DHCP. Par rapport à l'exercice de laboratoire "Lab répartition de charge avec Rapid Spanning-Tree", tout reste identique sauf le paramètre de passerelle.

## 4. Toplogie CCNA Core et Switchblock

![](https://www.lucidchart.com/publicSegments/view/aacc6247-aa9a-44b2-a1ba-43ccb81deab7/image.png)


## 5. Utilisation

Se rendre dans le dossier des livres de jeux :

```bash
cd
git clone https://github.com/goffinet/ansible-ccna-lab
cd ansible-ccna-lab
```

Tester la connectivité vers les périphériques :

```bash
ansible all -m ping
```


### 5.1. Inventaire et variables d'inventaire du livre de jeu ccna.yml

L'inventaire par défaut est défini comme suit (fichier `inventories/ccna/hosts`) et correspond à la topologie ccna (core + switchblock) :

```ini
[all:vars]
#method=modules # modules or templating not yet implemented
routing_ipv4='["eigrp4"]'
routing_ipv6='["eigrp6"]'
#routing_ipv4='["rip", "eigrp4", "ospfv2"]'
#routing_ipv6='["eigrp6", "ospfv3"]'

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

[cisco:children]
core
distribution
access

[cisco:vars]
ansible_user=root
ansible_ssh_pass=testtest
ansible_port=22
ansible_connection=network_cli
ansible_network_os=ios

```

Les configurations sont définies en YAML dans les fichiers de variables d'inventaire (dossiers `inventories/ccna/group_vars` et `inventories/ccna/host_vars`).

```raw
inventories/ccna
├── group_vars
│   ├── all       --> protocoles de routage ipv4/ipv6
│   └── blocks    --> variables vlans, switchports et stp mode
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

### 5.2. Livres de jeu

Les livres de jeu font appel à des rôles qui trouvent la valeur des variables dans l'inventaire.


Le playbook `tripod.yml` configure la topologie tripod :

```bash
ansible-playbook tripod.yml -v
```

Le playbook `blocks.yml` configure la topologie switchblock :

```bash
ansible-playbook switchblock.yml -v
```

Le playbook `ccna.yml` configure l'ensemble :

```bash
ansible-playbook ccna.yml -v
```

### 5.3. Diagnostic de base

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

## Notes

### Phase I

Portage en rôles **idempotents**.

Définition des variables dans `defaults/`.

Rôles à créer/améliorer :

* dhcp-relay
* ~~**fhrp4**~~ + delay
* ~~**fhrp6**~~ + delay
* **cdp / lldp**
* **syslog**
* **ntp** (+ auth)
* ~~eigrp4/6~~ / ~~ospfv2/v3~~ authentication
* **snmpv2c** / **snmpv3**
* **zbf**
* ra-config fine tuning / dhcpv6 stateless / dhcpv6 stateful / (rdnss)
* ppp / chap / pap / pppoe
* gre ipv4 / gre ipv6
* **security hardening**
* ~~dependencies~~ ? handlers ?
* ~~tags**~~

### Comment rendre une tâche ios_config idempotente ?

> "Être idempotent permet à une tâche définie d'être exécutée une seule fois ou des centaines de fois sans créer un effet contraire sur le système cible, ne provoquant un changement à une seule reprise. En d'autres mots, si un changement est nécessaire pour obtenir le système dans un état désiré, alors le changement est réalisé ; par contre si le périphérique est déjà dans l'état désiré, aucun changement n'intervient. Ce comportement est différent des pratiques de scripts personnalisés et de copier/coller de lignes de commandes. Quand on exécute les mêmes commandes ou scripts sur un même système de manière répétée, le taux d'erreur est souvent élevé."
>
> Extrait de: Jason Edelman. « Network Automation with Ansible. », O’Reilly Media, 2016.

Attention, Ansible autorise l'idempotence, mais selon le module utilisé, il faudra le manipuler pour atteindre cette exigence de conception.

1/ La section ["Why do the config modules always return true" de la "Ansible Network FAQ"](https://docs.ansible.com/ansible/latest/network/user_guide/faq.html#why-do-the-config-modules-always-return-changed-true-with-abbreviated-commands) explique ceci :

Les modules `*_config` d'Ansible Network comparent le texte des commandes que vous spécifiez dans les lignes au texte de la configuration. Si vous utilisez `shut` dans la section `lines` de la tâche, et que la configuration indique `shutdown`, le module retourne `changed=true` même si la configuration est déjà correcte. La tâche mettra à jour la configuration à chaque fois qu'elle s'exécutera.

Les commande utilisées avec Ansible pourraient ne pas êtres les mêmes commandes que celles trouvées dans la `running_config` : alors, les contrôles entre les lignes ne correspondent pas exactement, même s'ils produisent la même sortie.

2/ Il y a aussi la façon dont le module compare les lignes mises à jour avec la `running_config`. Par défaut, le module vérifie chaque ligne, mais il y a d'autres options. La [documentation](https://docs.ansible.com/ansible/latest/modules/ios_config_module.html) dit ceci à propos de l'argument `match` du module :

Instruit le module sur la façon d'effectuer la correspondance du jeu de commandes avec la configuration actuelle du périphérique. Si l'argument `match` est valorisé par `line`, les commandes sont mises en correspondance ligne par ligne (défaut). Si l'argument `match` est valorisé par `strict`, les lignes de commande sont mises en correspondance par rapport à la position. Si l'argument `match` est valorisé par `exact`, les lignes de commande doivent être de même nature. Enfin, si l'argument `match` est valorisé par `none`, le module ne tentera pas de comparer la configuration source avec la configuration en cours d'exécution sur le périphérique distant.

3/ L'option `after` contrôle l'application des changements aux interfaces :

L'ensemble des commandes ordonnées à ajouter à la fin de la pile de commandes si un changement doit être fait. Comme avec l'option `before`, cela permet au concepteur du livre de lecture d'ajouter un ensemble de commandes à exécuter après l'ensemble de commandes.

Combinée avec l'option `before`, on applique des commandes avant et après que les changements soient faits. Par exemple, on peut définir une réinitialisation en cinq minutes pour éviter une déconnexion à cause d'un problème de configuration, ou écrire les changements dans la ROM (bien que l'on puisse le faire avec l'option `save_when`).[^1]

[^1]: Texte original de [guzmonne](https://stackoverflow.com/users/1930817/guzmonne) en réponse à la question stackoverflow [How can I make my ios_config task idempotent?](https://stackoverflow.com/questions/57279642/how-can-i-make-my-ios-config-task-idempotent).

Aussi, l'argument `defaults` qu'il sera nécessaire d'activer avec la valeur `yes` spécifie s'il faut ou non collecter toutes les valeurs par défaut lors de l'exécution de la configuration du périphérique distant. Lorsqu'il est activé, le module obtient la configuration actuelle en lançant la commande `show running-config all`. En effet, des commandes comme `no shutdown` ou encore `ipv6 enable` ou encore `ipv4 routing` et beaucoup n'apparaissent pas avec la commande `show running-config`.

### Phase II

_tasks by jinja2 templating_

Rôles "immutables" qui agissent sur un modèle de fichier de configuration basé sur des choix d'infrastructure (des variables) et qui sera poussé sur les périphériques par la procédure `config replace flash:XXX force`.

"Immutable" roles by templating one config file based on infrastructure choices (variables) and pushed by `config replace flash:XXX force` procedure to the devices.

### Phase III

* Reporting ([role ansible-network.cisco_ios](https://galaxy.ansible.com/ansible-network/cisco_ios))
