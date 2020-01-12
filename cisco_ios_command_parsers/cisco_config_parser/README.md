cisco_config_parser
=========

A role using ansible-network.network-engine's command_parser to generate host_vars of ios device from the running-config.

A more complete and lighter alternative to ios_facts.

Requirements
------------
Ssh and privilege 15 on the device to retrieve the running-config.

vars retrieved
--------------

- hostname
- major version
- aaa
- vlan
- vrf
- interfaces
- line
- ... (more to come)

Check my example in tests/host_vars/CSR1000v1 extracted from the configuration here: files/CSR1000v1.ios

Dependencies
------------

Ansible-network.network-engine

How to test it
----------------

- git clone https://github.com/kvernNC/cisco_config_parser.git
- cd cisco_config_parser/tests/
- ansible-galaxy install -r roles/requirements.yml
- edit inventory and group_vars for adding your device
- ansible-playbook test.yml
- check the result in host_vars

How to use it in your Playbook
------------------------------
As host_vars aren't dynamically read by ansible, you should run this role on independant playbook and then run your playbook without ios_facts.

License
-------

BSD

Author Information
------------------

Kvern, contact me via github.
