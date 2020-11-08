---
layout: single
title: "Prise de connaissance des paramètres de configuration de Ansible"
permalink: /mise-en-place-du-lab-sur-gns3/prise-de-connaissance-des-parametres-configuration-ansible/
excerpt: " "
tags:
  - tutoriel
sidebar:
  nav: "menu"
date: 2020-05-24
---

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
- `strategy` : désigne la stratégie "linear" qui lance chaque tâche sur tous les hôtes concernés par un jeu avant de commencer la tâche suivante alors que la stratégie "free" permet à chaque hôte d'exécuter le jeu jusqu'à la fin aussi vite que possible.
- `gathering` : collecte ("implicit", par défaut) ou non ("explicit") les facts. Ici désactivé par défaut.
- `callback_whitelist` : affiche ou non des paramètres de temps (voir la section `[callback_profile_tasks]`).
- `display_ok_hosts` : active ou non l'affichage des tâches dont le statut est "OK" (utile pour vérifier l'idempotence).
- `display_skipped_hosts` : active ou non l'affichage des tâches dont le statut est "Skipped" (utile pour vérifier l'idempotence).
