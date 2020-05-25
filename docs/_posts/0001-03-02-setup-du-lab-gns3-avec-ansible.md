---
layout: single
title: "Setup du lab GNS3 avec Ansible"
permalink: /mise-en-place-du-lab-sur-gns3/setup-du-lab-gns3-avec-ansible/
excerpt: " "
tags:
  - tutoriel
sidebar:
  nav: "menu"
date: 2020-05-24
---

Un livre de jeu intitulé [`lab_setup.yml`](https://github.com/goffinet/ansible-ccna-lab/blob/master/playbooks/lab_setup.yml) monte automatiquement les topologies qui sont présentées plus bas sur un serveur GNS3. Il exploite [gns3fy](https://davidban77.github.io/gns3fy/), la collection Ansible [davidban77.gns3](https://galaxy.ansible.com/davidban77/gns3) et l'exemple [Collection of Ansible + GNS3 project examples](https://github.com/davidban77/demo-ansible-gns3) de [David Flores (aka: netpanda)](https://davidban77.hashnode.dev/). Les variables qui définissent les périphériques et leurs connexions sont situées dans le dossier [`playbooks/vars/`](https://github.com/goffinet/ansible-ccna-lab/blob/master/playbooks/vars/). Des dépendances python doivent être installées (voir fichier [requirements.txt](https://github.com/goffinet/ansible-ccna-lab/blob/master/requirements.txt)).

On peut installer les dépendances de la manière suivante :

```bash
pip install netaddr
pip install pexpect
pip install gns3fy
mazer install davidban77.gns3
```

Le livre de jeu crée une topologie CCNA (par défaut) sur un serveur GNS3, configure la gestion des routeurs et des commutateurs, duplique une seule fois (par défaut) le projet de base et supprime ce dernier. Les projets dupliqués sont nommés selon cette nomenclature `date-topologie-nb` : `2020-05-23-ccna-1`.

```bash
git clone https://github.com/goffinet/ansible-ccna-lab
cd playbooks
ansible-playbook lab_setup.yml
```

On peut choisir la topologie de base en précisant l'inventaire :

```bash
ansible-playbook lab_setup.yml -i inventories/ccna/hosts
```

On aussi préciser le nombre de topologies à dupliquer et le nom de base de chacun des projets créés, ici 3 avec le nom "testlab" :

```bash
ansible-playbook lab_setup.yml -i inventories/tripod/hosts -e "dest_name=testlab count=3"
```

Les différentes étapes du livre de jeu peuvent être controllées avec des "tags" Ansible :

- `create`
- `start`
- `provision`
- `duplicate`
- `remove`

<!--

Note : Pour les utilisateurs de la topologie GNS3 fournie en classe, sur certains voire sur tous les périphériques Cisco, il sera peut-être nécessaire de regénérer les clés RSA :

```shell
enable
configure terminal
crypto key generate rsa modulus 2048
exit
wr

```

-->
