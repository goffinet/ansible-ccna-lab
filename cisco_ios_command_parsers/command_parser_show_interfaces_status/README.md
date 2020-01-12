# command_parser_show_interfaces_status

This is a command parser for [__Ansible__](https://www.ansible.com/) [__network-engine__](https://github.com/ansible-network/network-engine).

It issues the Cisco IOS command **'show interfaces status'** and parses the output.

The file **show_interfaces_status.yml** is a playbook using the parser.
It can be used as an example and should be self-explanatory.


Inspiration came from this great blog:
https://termlen0.github.io/2018/06/26/observations/

## Example

Here is an example of how the output might look like:

```
 "Fa4": {
            "data": {
                "duplex": "auto",
                "interface": "Fa4",
                "name": "test interface4     ",
                "speed": "auto",
                "status": "notconnect",
                "type": "10/100BaseTX",
                "vlan": "1"
            }
```



___

Licensed under the [__Apache License Version 2.0__](https://www.apache.org/licenses/LICENSE-2.0)

Written by __farid@joubbi.se__

http://www.joubbi.se/monitoring.html

