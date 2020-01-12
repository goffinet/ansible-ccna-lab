# command_parser_show_ip_interface

This is a command parser for [__Ansible__](https://www.ansible.com/) [__network-engine__](https://github.com/ansible-network/network-engine).

It issues the Cisco IOS command **'show ip interface'** and parses the output.

The file **show_ip_interface.yml** is a playbook using the parser.
It can be used as an example and should be self-explanatory.


Inspiration came from this great blog:
https://termlen0.github.io/2018/06/26/observations/

## Example

Here is an example of how the output might look like:

```
    "Vlan252": {
        "config": {
            "helper": "192.168.1.37",
            "inbound_acl": "vrf-cool-acl",
            "ip_address": "10.4.38.126/26",
            "local_proxy_arp": "disabled",
            "mtu": "1500",
            "name": "Vlan252",
            "outgoing_acl": "not set",
            "proxy_arp": "enabled",
            "unicast_rpf": null
        }
    },
```



___

Licensed under the [__Apache License Version 2.0__](https://www.apache.org/licenses/LICENSE-2.0)

Written by __farid@joubbi.se__

http://www.joubbi.se/monitoring.html

