---
layout: single
title: "2. La gestion du réseau avec Ansible"
permalink: /gestion-ansible/
excerpt: " "
tags:
  - how-to
sidebar:
  nav: "menu1"
date: 2020-05-23
---

## Eléments

Pour la gestion des noeuds Cisco, le projet est basé sur trois éléments :

1. des livres de jeu qui peuvent en appeler d'autres nommés selon la **topologie** ;
2. ces livres de jeu configurent des hôtes d'inventaire avec des tâches organisées en **rôles** ;
3. les paramètres de la topologie sont configurés en tant que **variables d'inventaire selon un certain modèle de données**.

## Topologies

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

## Explication rapide

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
