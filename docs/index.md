# Ansible CCNA Lab

<!-- TOC depthFrom:2 depthTo:3 withLinks:1 updateOnSave:1 orderedList:0 -->

- [1. Résumé](#1-rsum)
- [2. Mise en place](#2-mise-en-place)
	- [2.1. Préparer des images Cisco IOSv pour GNS3](#21-prparer-des-images-cisco-iosv-pour-gns3)
	- [2.2. Configurer la station de contrôle](#22-configurer-la-station-de-contrle)
	- [2.3. Cloner le dépôt](#23-cloner-le-dpt)
	- [2.5. Examiner les paramètres de configuration de Ansible](#25-examiner-les-paramtres-de-configuration-de-ansible)
- [3. Topologies](#3-topologies)
	- [3.1. Topologie CCNA Gateway](#31-topologie-ccna-gateway)
	- [3.2. Topologie CCNA Bipod](#32-topologie-ccna-bipod)
	- [3.3. Topologie CCNA Tripod](#33-topologie-ccna-tripod)
	- [3.4. Topologie variante Router on a Stick](#34-topologie-variante-router-on-a-stick)
	- [3.5. Topologie CCNA Switchblock](#35-topologie-ccna-switchblock)
	- [3.6. Toplogie CCNA Tripod et Switchblock](#36-toplogie-ccna-tripod-et-switchblock)
- [4. Utilisation](#4-utilisation)
	- [4.1. Inventaire et variables d'inventaire du livre de jeu ccna.yml](#41-inventaire-et-variables-dinventaire-du-livre-de-jeu-ccnayml)
	- [4.2. Livres de jeu](#42-livres-de-jeu)
	- [4.3. Diagnostic de base](#43-diagnostic-de-base)
- [5. Notes](#5-notes)
	- [5.1. Comment rendre une tâche ios_config idempotente ?](#51-comment-rendre-une-tche-iosconfig-idempotente-)

<!-- /TOC -->

## 1. Résumé

On trouvera ici des livres de jeu inspirés des topologies et des sujets du Cisco CCNA (et plus) pour GNS3 (Cisco IOSv).

Leur but est uniquement pédagogique visant à lier les compétences de gestion du réseau du CCNA avec un outil IaC ("Infrastructure as Code") de gestion des configurations ("Configuration Management") comme Ansible et un gestionnaire de source ("Source Control Management") comme Git/Github.

Le projet est basé sur trois éléments : des livres de jeu qui peuvent en appeler d'autres nommés selon la **topologie** ; ces livres de jeu configurent des hôtes d'inventaire avec des tâches organisées en **rôles** ; les paramètres de la topologie sont configurés en tant que **variables d'inventaire selon un certain modèle de données**.

Les topologies sont organisées de la manière suivante :

```yaml
ccna:
  tripod:
    gateway:
    bipod:
    router_on_a_stick:
  switchblock:
```

Une topologie intitulée "ccna" est composée de deux topologies distinctes "tripod" et "switchblock". La topologie "tripod" trouve trois variantes amoindries : "gateway", "bipod", et "router_on_a_stick".

Expliqué rapidement :

* Le livre de jeu `ccna.yml` utilise l'inventaire par défaut `ccna` (`tripod` + `switchblock`). On trouve d'autres inventaires adaptés aux livres de jeu du même nom dans le dossier `inventories/`.
* Un livre le jeu devrait appeler un inventaire du même nom, par exemple : `ansible-playbook -i inventories/tripod/hosts tripod.yml`.
* On peut contrôler les tâches avec des _tags_ (définis sur les rôles) : `ansible-playbook ccna.yml --list-tags`.
* L'exécution des tâches est conditionnée par le modèle de donnée (variables d'inventaire), principalement fondé sur une liste de paramètres d'interface.
* L'exécution des rôles est conditionnée par :
  * une variable `ansible_network_os == 'ios'`;
  * la définition d'une variable de telle sorte que l'absence de paramètre évite l'exécution des tâches ("Skipped").
* Le protocole de routage est contrôlé à partir du livre de jeu avec les variables `ipv4.routing` et `ipv6.routing`. Il est conseillé d'en activer un seul pour une topologie. Des cas de "route redistribution" devraient être envisagés.
* Les livres de jeu exécutent les rôles dans un ordre logique ~~mais chacun trouve des dépendances de rôles définis~~.

## 2. Mise en place

Note : Pour les utilisateurs de la topologie GNS3 fournie en classe, sur certains voire sur tous les périphériques Cisco, il sera peut-être nécessaire de regénérer les clés RSA :

```raw
enable
configure terminal
crypto key generate rsa modulus 2048
exit
wr

```

La mise place de la solution demande quelques étapes décrites plus bas.

### 2.1. Préparer des images Cisco IOSv pour GNS3

Les livres de jeu sont testés avec [GNS3 Server](https://cisco.goffinet.org/ccna/cisco-ios-cli/installer-et-configurer-gns3/) et Qemu/KVM sous Linux.

Il y a trois types de périphériques utilisés dans les topologies.

Périphériques | Images Qemu/KVM | Commentaire
---|---|---
Routeur Cisco IOSv 15.6(2)T | `vios-adventerprisek9-m.vmdk.SPA.156-2.T` avec `IOSv_startup_config.img`  | [VIRL 1.3.296 (Aug. 2017 Release)](https://learningnetwork.cisco.com/docs/DOC-33132)
Commutateur Cisco IOSv L2/L3  | `vios_l2-adventerprisek9-m.03.2017.qcow2`  | [VIRL 1.3.296 (Aug. 2017 Release)](https://learningnetwork.cisco.com/docs/DOC-33132)
Poste de travail L2 à L7, Station de contrôle  | [`centos7.qcow2`](http://get.goffinet.org/kvm/centos7.qcow2)  |  Le [fichier d'appliance GNS3](http://get.goffinet.org/gns3a/centos7.gns3a)

Les livres de jeu peuvent vérifier la nature du périphérique utilisé de type Cisco et de type routeur ou commutateur à partir de variables d'inventaire.

#### 2.1.1. Routeurs

On utilise des images IOSv `vios-adventerprisek9-m.vmdk.SPA.156-2.T` pour les routeurs L3 avec 8 interfaces GigabitEthernet.

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

#### 2.1.2 Commutateurs

On utilise des images IOSv-L2 `vios_l2-adventerprisek9-m.03.2017.qcow2` pour les commutateurs multicouches.

L'interface `GigabitEthernet3/3` sert de console de contrôle TCP/IP et ne participe pas au routage.

SSH est activé de la manière suivante, sur AS1 par exemple :

```raw
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

### 2.2. Configurer la station de contrôle

La station de contrôle connecte tous les périphériques en SSH.

Le logiciel Ansible y est fraîchement installé (avec la libraire python netaddr) avec `pip` ou à partir de repos.

La station de contrôle offre un service DHCP avec enregistrement dynamique des noms d'hôte dans un serveur DNS (dnsmasq).

```bash
hostnamectl set-hostname controller
yum -y remove ansible
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install --upgrade pip
pip install ansible
pip install ansible-lint
pip install ansible netadrr
#yum -y install ansible
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
systemctl enable dnsmasq
shutdown -r now

```

### 2.3. Cloner le dépôt

Il est nécessaire de cloner le dépot sur la machine de contrôle.

```bash
git clone https://github.com/goffinet/ansible-ccna-lab
cd ansible-ccna-lab/playbooks
```

Les livres de jeu sont disponibles dans le dossier `ansible-ccna-lab/playbooks` et se lancent à partir de ce dossier. On peut aussi les utiliser comme "collection" Ansible : voir [Using collections in a Playbook](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html#using-collections-in-a-playbook).

On y trouve l'arborescence suivante :

```raw
ansible-ccna-lab/playbooks/
├── ansible.cfg  --> fichier de configuration par défaut
├── ccna.yml     --> livre de jeu de la topologie ccna
├── configs/     --> dossier par défaut des fichiers de configuration
├── demos/       --> livres de jeu de démo / test
├── files/       --> fichiers statiques spécifiques à utiliser avec les livres de jeu
├── gateway.yml            --> livre de jeu de la topologie gateway
├── inventories/           --> dossier d'inventaires
├── roles/ -> ../roles     --> dossier des rôles utilisés par les livres de jeu
├── router_on_a_stick.yml  --> livre de jeu de la topologie router_on_a_stick
├── bipod.yml       --> livre de jeu de la topologie bipod
├── switchblock.yml        --> livre de jeu de la topologie switchblock
├── tasks/       --> tâches spécifiques à utiliser avec les livres de jeu
├── templates/   --> modèles spécifiques à utiliser avec les livres de jeu
├── tripod.yml   --> livre de jeu de la topologie tripod
└── vars         --> variables spécifiques à utiliser dans le livre de jeu
```

Modèle basé sur [https://github.com/bcoca/collection](https://github.com/bcoca/collection).

### 2.5. Examiner les paramètres de configuration de Ansible

Le fichier de configuration `ansible.cfg` dans le dossier `ansible-ccna-lab/playbooks` configure par défaut le comportement de Ansible :

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
callback_whitelist = profile_tasks
#display_ok_hosts = no
#display_skipped_hosts = no
#[callback_profile_tasks]
#task_output_limit = 100
```

La section `[defaults]` définit différentes variables comportementales du logiciel Ansible utiles à nos exécutions en comparaison aux paramètres par défaut :

- `inventory` : désigne l'emplacement de l'inventaire par défaut ici `./inventories/ccna/hosts`.
- `roles_path` : désigne les emplacements par défaut des rôles.
- `host_key_checking` : active ou non la vérification des clés SSH, ici désactivée.
- `retry_files_enabled` active ou non la génération de fichier "[retry](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#retry-files-enabled)".
- `log_path` : désigne l'emplacement et le nom du fichier de log.
- `forks` : désigne le nombre d'hôtes à controller en paralèlle (5 par défaut).
- `strategy` : désigne la stratégie "linear" lance chaque tâche sur tous les hôtes concernés par un jeu avant de commencer la tâche suivante alors que la stratégie "free" permet à chaque hôte d'exécuter le jeu jusqu'à la fin aussi vite que possible.
- `gathering` : collecte ("implicit", par défaut) ou non ("explicit") les facts. Ici désactivé par défaut.
- `callback_whitelist` : affiche ou non des paramètres de temps (voir la section `[callback_profile_tasks]`).
- `display_ok_hosts` : active ou non l'affichage des tâches dont le statut est "OK" (utile pour vérifier l'idempotence).
- `display_skipped_hosts` : active ou non l'affichage des tâches dont le statut est "Skipped" (utile pour vérifier l'idempotence).

## 3. Topologies

Les topologies réseau développées sont décrites dans différents inventaires et se configurent avec un livre de jeu du même nom :

- "gateway" : un seul routeur connecte l'Internet et offre des services au LAN comme DHCP et RDNSS
- "bipod" : topologie d'interconnexion de deux LANs distants
- "tripod" : topologie de base maillée à trois routeurs avec un accès à l'Internet
- "router_on_a_stick" : topologie d'apprentissage des VLANs
- "switchblock" : topologie de commutateurs de couche Access et Distribution
- "ccna" : topologies "tripod" et "switchblock" connectées entre elles

### 3.1. Topologie CCNA Gateway

Un seul routeur Cisco qui connecte l'Internet et qui offre des services au LAN comme DHCP et RDNSS.

Références :

* [Lab passerelle Internet](https://cisco.goffinet.org/ccna/services-infrastructure/lab-passerelle-internet/)

![Topologie CCNA Gateway](https://www.lucidchart.com/publicSegments/view/d8a42bbc-5192-48b9-a630-2e968dcf6f43/image.png)

Diagramme : Topologie CCNA Gateway

### 3.2. Topologie CCNA Bipod

Connexion point-à-point entre R1 et R2.

![Topologie Bipod](https://www.lucidchart.com/publicSegments/view/46f2b887-0e06-40e6-b45c-b07f449adf08/image.png)

Références :

* [Lab routage statique simple](https://cisco.goffinet.org/ccna/routage/lab-routage-statique-simple/)
* [Lab routage RIPv2 simple](https://cisco.goffinet.org/ccnp/rip/lab-ripv2-simple/)
* [Lab Routage OSPF simple](https://cisco.goffinet.org/ccna/ospf/lab-routage-ospf-simple/)
* [Lab de routage et services IPv4/IPv6](https://cisco.goffinet.org/ccna/services-infrastructure/lab-routage-et-services-ipv4-ipv6/)

Diagramme : Topologie CCNA Bipod

### 3.3. Topologie CCNA Tripod

Cette topologie maillée à trois routeurs peut être désignée par "tripod". Elle est la couche "Core" de la topologie CCNA complète.

#### 3.3.1. Topologie logique

![Topologie CCNA Tripod](https://www.lucidchart.com/publicSegments/view/3328e715-30bf-48a8-a48d-1ff276420520/image.png)

#### 3.3.2. Brève description

Trois périphériques IOSv interconnectés entre eux :

* R1
* R2
* R3

Routeur | Interface | Adresse IPv4 | Adresses IPv6 | Description
--- | --- | --- | --- | ---
R1 | G0/0 | `192.168.1.1/24` | `FE80::1`, `FD00:FD00:FD00:1::1/64` | LAN de R1
R1 | G0/2 | `192.168.225.1/24` | `FE80::1` | Connexion vers R2
R1 | G0/3 | `192.168.227.1/24` | `FE80::1` | Connexion vers R3
R2 | G0/0 | `192.168.33.1/24` | `FE80::2`, `FD00:FD00:FD00:2::1/64` | LAN de R2
R2 | G0/1 | `192.168.225.2/24` | `FE80::2` | Connexion vers R1
R2 | G0/3 | `192.168.226.1/24` | `FE80::2` | Connexion vers R3
R3 | G0/0 | `192.168.65.1/24` | `FE80::3`, `FD00:FD00:FD00:3::1/64` | LAN de R3
R3 | G0/1 | `192.168.227.2/24` | `FE80::3` | Connexion vers R1
R3 | G0/2 | `192.168.226.2/24` | `FE80::3` | Connexion vers R2

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

### 3.4. Topologie variante Router on a Stick

Variante de la topologie Tripod en utilisant un Trunk Vlan entre R1 et SW0 ainsi qu'entre SW0 et SW1.

![Topologie variante Router on a Stick](https://www.lucidchart.com/publicSegments/view/4f58dfa5-3070-4fd1-9efd-87c8c321abb0/image.png)

Diagramme : Topologie variante Router on a Stick

Références :

* [Lab VLAN de base](https://cisco.goffinet.org/ccna/vlans/lab-vlan-base-cisco-ios/)

### 3.5. Topologie CCNA Switchblock

Cette seconde topologie "switchblock" met en oeuvre des _commutateurs_. Cette topologie est plus complexe et se connecte à la topologie "tripod". Elle met en oeuvre les couches "distribution" et "access".

Références :

* [Technologies VLANs](https://cisco.goffinet.org/ccna/vlans/)
* [Redondance de liens](https://cisco.goffinet.org/ccna/redondance-de-liens/)
* [Disponibilité dans le LAN](https://cisco.goffinet.org/ccna/disponibilite-lan/)

#### 3.5.1. Topologie avec redondance de passerelle HSRP

![Topologie avec redondance de passerelle HSRP](https://www.lucidchart.com/publicSegments/view/84f170f5-af2b-44c1-8f6d-d169399dbba2/image.png)


#### 3.5.2. VLANs

VLAN | Ports Access (AS1 et AS2) | plage d'adresse | Passerelle par défaut
--- | --- | --- | ---
VLAN 10 | `g2/0` | `172.16.10.0/24` | **`172.16.10.254`**
VLAN 20 | `g2/1` | `172.16.20.0/24` | **`172.16.10.254`**
VLAN 30 | `g2/2` | `172.16.30.0/24` | **`172.16.10.254`**
VLAN 40 | `g2/3` | `172.16.40.0/24` | **`172.16.10.254`**
VLAN 99 | VLAN natif | Management

#### 3.5.3. Ports Etherchannel et Trunk VLANs

PortChannel | ports physiques | Commutateurs
--- | --- | ---
po1 | `g0/0`,`g1/0` | AS1 - DS1
po2 | `g0/1`,`g1/1` | AS1 - DS2
po3 | `g0/2`,`g1/2` | DS1 - DS2
po4 | `g0/0`,`g1/0` | AS2 - DS2
po5 | `g0/1`,`g1/1` | AS2 - DS1

#### 3.5.4. Spanning-Tree

VLANs | DS1 | DS2
--- | --- | ---
VLANs 1,10,30,99 | `root primary` | `root secondary`
VLANs 20,40 | `root secondary` | `root primary`

#### 3.5.5. Plan d'adressage

Commutateur | Interface | Adresse IPv4 | Adresse(s) IPv6
--- | --- | --- | ---
DS1 | VLAN10 | `172.16.10.252/24` | `FD00:1AB:10::1/64`
DS1 | VLAN20 | `172.16.20.252/24` | `FD00:1AB:20::1/64`
DS1 | VLAN30 | `172.16.30.252/24` | `FD00:1AB:30::1/64`
DS1 | VLAN40 | `172.16.40.252/24` | `FD00:1AB:40::1/64`
DS2 | VLAN10 | `172.16.10.253/24` | `FD00:1AB:10::2/64`
DS2 | VLAN20 | `172.16.20.253/24` | `FD00:1AB:20::2/64`
DS2 | VLAN30 | `172.16.30.253/24` | `FD00:1AB:30::2/64`
DS2 | VLAN40 | `172.16.40.253/24` | `FD00:1AB:40::2/64`

#### 3.5.6. HSRP

Commutateur | Interface | Adresse IPv4 virtuelle | Adresse IPv6 virtuelle | Group | Priorité
--- | --- | --- | --- | --- | ---
DS1 | VLAN10 | `172.16.10.254/24` | `FE80::d:1/64` | 10/16 | 150, prempt
DS1 | VLAN20 | `172.16.20.254/24` | `FE80::d:1/64` | 20/26 | default
DS1 | VLAN30 | `172.16.30.254/24` | `FE80::d:1/64` | 30/36 | 150, prempt
DS1 | VLAN40 | `172.16.40.254/24` | `FE80::d:1/64` | 40/46 | default
DS2 | VLAN10 | `172.16.10.254/24` | `FE80::d:2/64` | 10/16 | default
DS2 | VLAN20 | `172.16.20.254/24` | `FE80::d:2/64` | 20/26 | 150, prempt
DS2 | VLAN30 | `172.16.30.254/24` | `FE80::d:2/64` | 30/36 | default
DS2 | VLAN40 | `172.16.40.254/24` | `FE80::d:2/64` | 40/46 | 150, prempt

#### 3.5.7. Ressources requises

*	4 commutateurs (vios_l2 Software (vios_l2-ADVENTERPRISEK9-M), Experimental Version 15.2(20170321:233949))
*	8 PCs (Centos 7 KVM ou Ubuntu Docker)
*	(Câbles de console pour configurer les périphériques Cisco IOS via les ports de console)
*	Câbles Ethernet conformément à la topologie

#### 3.5.8. Explication

Dans l'exercice de laboratoire "Lab répartition de charge avec Rapid Spanning-Tree", nous avons appris à déployer Rapid Spanning-Tree entre la couche Distribution et la couche Access. Il manque manifestement une sûreté au niveau de la passerelle par défaut que constitue le commutateur de Distribution. Afin d'éviter ce point unique de rupture, on apprendra à configurer et vérifier HSRP. Dans cette topologie une passerelle devient routeur "Active" pour certains VLANs et reste en HSRP "Standby" pour d'autres VLANs et inversément.

On trouvera plus bas les fichiers de configuration qui déploient la solution  VLANs, Trunking, Etherchannel, Rapid Spanning-Tree, SVI IPv4 et IPv6 et DHCP. Par rapport à l'exercice de laboratoire "Lab répartition de charge avec Rapid Spanning-Tree", tout reste identique sauf le paramètre de passerelle.

### 3.6. Toplogie CCNA Tripod et Switchblock

Cette topologie interconnecte les topologies "tripod" et "switchblock".

![](https://www.lucidchart.com/publicSegments/view/aacc6247-aa9a-44b2-a1ba-43ccb81deab7/image.png)

## 4. Utilisation

Se rendre dans le dossier des livres de jeu `ansible-ccna-lab/playbooks/` :

```bash
cd
git clone https://github.com/goffinet/ansible-ccna-lab
cd ansible-ccna-lab/playbooks
```

Tester la connectivité vers les périphériques :

```bash
ansible all -m ping
```

### 4.1. Inventaire et variables d'inventaire du livre de jeu ccna.yml

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

[cisco:vars]
ansible_user=root
ansible_ssh_pass=testtest
ansible_port=22
ansible_connection=network_cli
ansible_network_os=ios


```

Les configurations sont définies en YAML dans les fichiers de variables d'inventaire (fichier au nom du groupe dans le dossier `inventories/ccna/group_vars` et fichier au nom de l'hôte dans le dossier `inventories/ccna/host_vars`).

```raw
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

### 4.2. Livres de jeu

Les livres de jeu (`playbooks/`) font appel à des rôles qui trouvent la valeur des variables dans l'inventaire.


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

### 4.3. Diagnostic de base

_à améliorer_

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

## 5. Notes

### 5.1. Comment rendre une tâche ios_config idempotente ?

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

Combinée avec l'option `before`, on applique des commandes avant et après que les changements soient faits. Par exemple, on peut définir une réinitialisation en cinq minutes pour éviter une déconnexion à cause d'un problème de configuration, ou écrire les changements dans la ROM (bien que l'on puisse le faire avec l'option `save_when`).<sup>1</sup>

<sup>1</sup> Texte original de [guzmonne](https://stackoverflow.com/users/1930817/guzmonne) en réponse à la question stackoverflow [How can I make my ios_config task idempotent?](https://stackoverflow.com/questions/57279642/how-can-i-make-my-ios-config-task-idempotent).

Aussi, l'argument `defaults` qu'il sera nécessaire d'activer avec la valeur `yes` spécifie s'il faut ou non collecter toutes les valeurs par défaut lors de l'exécution de la configuration du périphérique distant. Lorsqu'il est activé, le module obtient la configuration actuelle en lançant la commande `show running-config all`. En effet, des commandes comme `no shutdown` ou encore `ipv6 enable` ou encore `ipv4 routing` et beaucoup n'apparaissent pas avec la commande `show running-config`.

#### Phase I

Tendre vers des rôles **idempotents** avec des [modules standards](https://docs.ansible.com/ansible/latest/modules/list_of_network_modules.html#ios).

Usage du filtre jinja2 [ipaddr](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters_ipaddr.html#playbooks-filters-ipaddr), voir [playbooks/ipaddr.yml](https://github.com/goffinet/ansible-ccna-lab/blob/master/playbooks/ipaddr.yml).

Structure en "collection" Ansible. [Using collections in a Playbook](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html#using-collections-in-a-playbook).

* définir des paramètres par défaut
* revoir les conditions, les boucles

Rôles à améliorer :

* nat sur les interfaces
* contrôle d'IPv6
* dhcp-relay
* ~~**fhrp4**~~ + delay
* ~~**fhrp6**~~ + delay
* ~~eigrp4/6~~ / ~~ospfv2/v3~~ authentication

Rôles à créer :

* IPv6 default route poisoning benefits to FD00::/8 as best route
* **cdp / lldp**
* **syslog**
* **ntp** (+ auth)
* **snmpv2c** / **snmpv3**
* **zbf**
* IPv6 Addresses Management :
  * ra-config fine tuning
  * dhcpv6 stateless
  * dhcpv6 stateful
  * rdnss ra option
* ppp / chap / pap / pppoe
* gre ipv4 / gre ipv6
* **security hardening**
* IPv6 default route poisoning benefits to FD00::/8 as best route
* ~~dependencies~~ ? handlers ?


#### Phase II

_tasks by jinja2 templating_

Rôles "immutables" qui agissent sur un modèle de fichier de configuration basé sur des choix d'infrastructure (des variables) et qui sera poussé sur les périphériques par la procédure `config replace flash:XXX force`.

"Immutable" roles by templating one config file based on infrastructure choices (variables) and pushed by `config replace flash:XXX force` procedure to the devices.

#### Phase III

Reporting ([role ansible-network.cisco_ios](https://galaxy.ansible.com/ansible-network/cisco_ios))
