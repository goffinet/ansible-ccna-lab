# command_parser_ping

This is a command parser for [__Ansible__](https://www.ansible.com/) [__network-engine__](https://github.com/ansible-network/network-engine).

It issues the Cisco IOS command **'ping'** and parses the output.

The file **ping.yml** is a playbook using the parser.
It can be used as an example and should be self-explanatory.


Inspiration came from this great blog:
https://termlen0.github.io/2018/06/26/observations/

## Example

```
$ ansible-playbook ping.yml --limit switch.example.com --extra-vars dst="192.168.0.1 vrf=1150"
```
Here is an example of how the output might look like:

```
{
    "destination_address": "192.168.0.1",
    "dst": "192.168.0.1",
    "success_rate": "100",
    "vrf": "1150"
}
```

Specifying **dst** is mandatory since that is the destination address of the ping.

The **vrf** variable is not mandatory. The default routing domain will be used if it is not specified.


___

Licensed under the [__Apache License Version 2.0__](https://www.apache.org/licenses/LICENSE-2.0)

Written by __farid@joubbi.se__

http://www.joubbi.se/monitoring.html

https://github.com/network-automation/cisco_ios_command_parsers

