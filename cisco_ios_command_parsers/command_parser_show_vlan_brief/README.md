# command_parser_show_vlan_brief

This is a command parser for [__Ansible__](https://www.ansible.com/) [__network-engine__](https://github.com/ansible-network/network-engine).

It issues the Cisco IOS command **'show vlan brief'** and parses the output.

The file **show_vlan_brief.yml** is a playbook using the parser.
It can be used as an example and should be self-explanatory.


Inspiration came from this great blog:
https://termlen0.github.io/2018/06/26/observations/

## Example

Here is an example of how the output might look like:

```
    "100": {
        "data": {
            "name": "Management",
            "status": "active",
            "vlan": "100"
        }
    },
```



___

Licensed under the [__Apache License Version 2.0__](https://www.apache.org/licenses/LICENSE-2.0)

Written by __farid@joubbi.se__

http://www.joubbi.se/monitoring.html

https://github.com/network-automation/cisco_ios_command_parsers

