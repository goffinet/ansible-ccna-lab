---
layout: single
title: "Notes et Todo"
permalink: /notes-todo/
excerpt: " "
tags:
  - tutoriel
sidebar:
  nav: "menu1"
date: 2020-05-24
---

## 6.1. Comment rendre une tâche ios_config idempotente ?

> "Être idempotent permet à une tâche définie d'être exécutée une seule fois ou des centaines de fois sans créer un effet contraire sur le système cible, ne provoquant un changement à une seule reprise. En d'autres mots, si un changement est nécessaire pour obtenir le système dans un état désiré, alors le changement est réalisé ; par contre si le périphérique est déjà dans l'état désiré, aucun changement n'intervient. Ce comportement est différent des pratiques de scripts personnalisés et de copier/coller de lignes de commandes. Quand on exécute les mêmes commandes ou scripts sur un même système de manière répétée, le taux d'erreur est souvent élevé."
>
> Extrait de: Jason Edelman. « Network Automation with Ansible. », O’Reilly Media, 2016.

Attention, Ansible autorise l'idempotence, mais selon le module utilisé, il faudra le manipuler pour atteindre cette exigence de conception.

1/ La section ["Why do the config modules always return true" de la "Ansible Network FAQ"](https://docs.ansible.com/ansible/latest/network/user_guide/faq.html#why-do-the-config-modules-always-return-changed-true-with-abbreviated-commands) explique ceci :

Les modules `*_config` d'Ansible Network comparent le texte des commandes que vous spécifiez dans les lignes au texte de la configuration. Si vous utilisez `shut` dans la section `lines` de la tâche, et que la configuration indique `shutdown`, le module retourne `changed=true` même si la configuration est déjà correcte. La tâche mettra à jour la configuration à chaque fois qu'elle s'exécutera.

Les commande utilisées avec Ansible pourraient ne pas être les mêmes commandes que celles trouvées dans la `running_config` : alors, les contrôles entre les lignes ne correspondent pas exactement, même s'ils produisent la même sortie.

2/ Il y a aussi la façon dont le module compare les lignes mises à jour avec la `running_config`. Par défaut, le module vérifie chaque ligne, mais il y a d'autres options. La [documentation](https://docs.ansible.com/ansible/latest/modules/ios_config_module.html) dit ceci à propos de l'argument `match` du module :

Instruit le module sur la façon d'effectuer la correspondance du jeu de commandes avec la configuration actuelle du périphérique. Si l'argument `match` est valorisé par `line`, les commandes sont mises en correspondance ligne par ligne (défaut). Si l'argument `match` est valorisé par `strict`, les lignes de commande sont mises en correspondance par rapport à la position. Si l'argument `match` est valorisé par `exact`, les lignes de commande doivent être de même nature. Enfin, si l'argument `match` est valorisé par `none`, le module ne tentera pas de comparer la configuration source avec la configuration en cours d'exécution sur le périphérique distant.

3/ L'option `after` contrôle l'application des changements aux interfaces :

L'ensemble des commandes ordonnées à ajouter à la fin de la pile de commandes si un changement doit être fait. Comme avec l'option `before`, cela permet au concepteur du livre de lecture d'ajouter un ensemble de commandes à exécuter après l'ensemble de commandes.

Combinée avec l'option `before`, on applique des commandes avant et après que les changements soient faits. Par exemple, on peut définir une réinitialisation en cinq minutes pour éviter une déconnexion à cause d'un problème de configuration, ou écrire les changements dans la ROM (bien que l'on puisse le faire avec l'option `save_when`).<sup>1</sup>

<sup>1</sup> Texte original de [guzmonne](https://stackoverflow.com/users/1930817/guzmonne) en réponse à la question stackoverflow [How can I make my ios_config task idempotent?](https://stackoverflow.com/questions/57279642/how-can-i-make-my-ios-config-task-idempotent).

Aussi, l'argument `defaults` qu'il sera nécessaire d'activer avec la valeur `yes` spécifie s'il faut ou non collecter toutes les valeurs par défaut lors de l'exécution de la configuration du périphérique distant. Lorsqu'il est activé, le module obtient la configuration actuelle en lançant la commande `show running-config all`. En effet, des commandes comme `no shutdown` ou encore `ipv6 enable` ou encore `ipv4 routing` et beaucoup n'apparaissent pas avec la commande `show running-config`.

## 6.2. Phase I : roles ios_config

- [x] Tendre vers des rôles **idempotents** avec des [modules standards](https://docs.ansible.com/ansible/latest/modules/list_of_network_modules.html#ios).
- [x] Usage du filtre jinja2 [ipaddr](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters_ipaddr.html#playbooks-filters-ipaddr), voir [playbooks/ipaddr.yml](https://github.com/goffinet/ansible-ccna-lab/blob/master/playbooks/demos/ipaddr.yml).
- [x] Structure en "collection" Ansible. [Using collections in a Playbook](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html#using-collections-in-a-playbook).
- [x] Définir des paramètres par défaut.
- [ ] Revoir les conditions, les boucles, les tags

Rôles à améliorer :

* [ ] nat sur les interfaces
* [ ] contrôle d'IPv6
* [ ] dhcp-relay
* [ ] ~~**fhrp4**~~ + delay
* [ ] ~~**fhrp6**~~ + delay
* [ ] ~~eigrp4/6~~ / ~~ospfv2/v3~~ authentication

Rôles à créer :

* [ ] RDNSS
* [ ] **cdp** / **lldp**
* [ ] **syslog**
* [ ] **ntp** (+ auth)
* [ ] **snmpv2c** / **snmpv3**
* [ ] **zbf**
* [ ] IPv6 Addresses Management :
    * [ ] ra-config fine tuning
    * [ ] dhcpv6 stateless
    * [ ] dhcpv6 stateful
* [ ] gre ipv4 / gre ipv6
* [ ] **security hardening**
* [ ] IPv6 default route poisoning benefits to `FD00::/8` as best route ?
* [ ] ~~dependencies~~ ? handlers ?
* [ ] ppp / chap / pap / pppoe
* [ ] bgp / vrf / ip-mpls
* [ ] dhcp snooping
* [ ] dai

## 6.3. Phase II : immutabilité

_tasks by jinja2 templating_, "boilerplate config"

Rôles "immutables" qui agissent sur un modèle de fichier de configuration basé sur des choix d'infrastructure (des variables) et qui sera poussé sur les périphériques par la procédure `config replace flash:XXX force`.

## 6.4. Phase III : Reporting et documentation

* Reporting ([role ansible-network.cisco_ios](https://galaxy.ansible.com/ansible-network/cisco_ios)) :
  * Documentation de la topologie (classique, énoncé) sur base des facts (parsing) et
  * Surveillance des interfaces et des services
