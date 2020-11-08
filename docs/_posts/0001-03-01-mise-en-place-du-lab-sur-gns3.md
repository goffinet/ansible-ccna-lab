---
layout: single
title: "La mise en place du lab sur GNS3"
permalink: /mise-en-place-du-lab-sur-gns3/
excerpt: " "
toc: false
tags:
  - tutoriel
sidebar:
  nav: "menu"
date: 2020-05-24
---

La mise en place du lab se réalise sur le serveur GNS3 ou sur une station qui dispose d'un accès au serveur.[^1] Il correspond à quelques étapes :

- Créer un projet GNS3 avec des périphériques interconnectés.
- Placer une station de contrôle avec Ansible et y connecter les périphériques à gérer.
- Préparer les images des noeuds Cisco pour une gestion avec Ansible à partir de la station de contrôle.

[^1]: Pour installer GNS3 avec Ansible, on fera référence à un autre projet : ~~[ansible-install-gns3-server](https://github.com/goffinet/ansible-install-gns3-server)~~.
