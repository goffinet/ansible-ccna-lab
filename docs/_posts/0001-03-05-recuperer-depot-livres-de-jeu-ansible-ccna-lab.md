---
layout: single
title: "Récupérer le dépôt des livres de jeu Ansible"
permalink: /mise-en-place-du-lab-sur-gns3/recuperer-depot-livres-de-jeu-ansible-ccna-lab/
excerpt: " "
tags:
  - tutoriel
sidebar:
  nav: "menu"
date: 2020-05-24
---

Il est nécessaire de cloner le dépot sur la machine de contrôle fraîchement configurée.

```bash
git clone https://github.com/goffinet/ansible-ccna-lab
cd ansible-ccna-lab/playbooks
```

Les livres de jeu sont disponibles dans le dossier `ansible-ccna-lab/playbooks` et se lancent à partir de ce dossier. On peut aussi les utiliser comme "collection" Ansible : voir [Using collections in a Playbook](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html#using-collections-in-a-playbook).

On y trouve l'arborescence suivante :

```
ansible-ccna-lab/playbooks/
├── ansible.cfg  --> fichier de configuration par défaut
├── bipod.yml    --> livre de jeu de la topologie bipod
├── ccna.yml     --> livre de jeu de la topologie ccna
├── configs/     --> dossier par défaut des fichiers de configuration
├── demos/       --> livres de jeu de démo / test
├── files/       --> fichiers statiques spécifiques à utiliser avec les livres de jeu
├── gateway.yml            --> livre de jeu de la topologie gateway
├── inventories/           --> dossier d'inventaires
├── lab_setup.yml          --> livre de jeu qui déploie une topologie sur GNS3
├── library                --> script utilisé par le livre de jeu lab_setup.yml
├── networking-workshop.yml   --> livre de jeu de la topologie networking-workshop
├── restore_config.yml     --> restaure des configurations par défaut
├── roles/ -> ../roles     --> dossier des rôles utilisés par les livres de jeu
├── router_on_a_stick.yml  --> livre de jeu de la topologie router_on_a_stick
├── switchblock.yml        --> livre de jeu de la topologie switchblock
├── tasks/       --> tâches spécifiques à utiliser avec les livres de jeu
├── templates/   --> modèles spécifiques à utiliser avec les livres de jeu
├── tripod.yml   --> livre de jeu de la topologie tripod
└── vars         --> variables spécifiques à utiliser dans un livre de jeu
```

Modèle de collection basé sur [https://github.com/bcoca/collection](https://github.com/bcoca/collection).
