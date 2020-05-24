---
layout: single
title: "Configuration de la station de contrôle"
permalink: /mise-en-place-du-lab-sur-gns3/configuration-de-la-station-de-controle/
excerpt: " "
tags:
  - tutoriel
sidebar:
  nav: "menu"
date: 2020-05-24
---

La station a besoin d'être configurée mannuellement.

La station de contrôle connecte tous les périphériques en SSH. Le logiciel Ansible y est fraîchement installé (avec la libraire python netaddr) avec `pip` ou à partir de repos.

La station de contrôle offre un service DHCP avec enregistrement dynamique des noms d'hôte dans un serveur DNS (dnsmasq). Un serveur rsyslog écoute sur les ports TCP514 et UDP514.

On trouve des scripts de préparation d'une station de contrôle Centos et Ubuntu dans le dossier [tests/](https://github.com/goffinet/ansible-ccna-lab/blob/master/tests/). L'interface `eth0` contrôle les périphériques et l'interface `eth1` donne accès à l'Internet.

On peut rapidement innstaller un contrôleur sous Centos :

```bash
curl -s https://raw.githubusercontent.com/goffinet/ansible-ccna-lab/master/tests/centos-controller.sh -o setup.sh
bash -x ./setup.sh
```

Si la version libre de Ansible Tower (Ansible AWX) vous intéresse, vous pouvez l'installer via ce script (4Go RAM et 2 vcpus) sur un station Ubuntu :

```bash
curl -s https://raw.githubusercontent.com/goffinet/ansible-ccna-lab/master/tests/ubuntu-controller.sh -o setup.sh
bash -x ./setup.sh
```

Et puis :

```bash
curl -s https://raw.githubusercontent.com/goffinet/ansible-ccna-lab/master/tests/awx-setup.sh -o awx-setup.sh
bash -x ./awx-setup.sh
```
