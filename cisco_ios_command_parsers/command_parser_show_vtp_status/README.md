# command_parser_show_vtp_status

This is a command parser for [__Ansible__](https://www.ansible.com/) [__network-engine__](https://github.com/ansible-network/network-engine).

It issues the Cisco IOS command **'show vtp status'** and parses the output.

The file **show_vtp_status.yml** is a playbook using the parser.
It can be used as an example and should be self-explanatory.


Inspiration came from this great blog:
https://termlen0.github.io/2018/06/26/observations/

## Example

Here is an example of how the output might look like:

```
{
    "configuration_last_modified": "10.1.1.1 at 1-16-19 11:24:12",
    "configuration_revision": "74",
    "device_id": "aaaa.aaaa.aaaa",
    "existing_vlans": "34",
    "max_vlans": "1005",
    "md5_digest": "0x8F 0x11 0xB9 0x7D 0x20 0x65 0xCE 0x0D ",
    "vtp_domain": "domain_name",
    "vtp_mode": "Client",
    "vtp_pruning_mode": "Enabled",
    "vtp_traps_generation": "Disabled",
    "vtp_v2_mode": null,
    "vtp_version_capable": "1 to 3",
    "vtp_version_running": "2"
}
```



___

Licensed under the [__Apache License Version 2.0__](https://www.apache.org/licenses/LICENSE-2.0)

Written by __farid@joubbi.se__

http://www.joubbi.se/monitoring.html

