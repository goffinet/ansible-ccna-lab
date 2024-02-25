# Linux Management from the Centos Controller

How to manage linux hosts with Ansible from the controller without the management network.

On any or some distribution switch, enable IPv4 EIGRP dynamic routing for the management network:

```bash
conf t
router eigrp 1
  network 11.12.13.0
```

## Dynamic routing

FRRouting should be installed on the centos controller.

To load an EIGRP config:

```bash
vtysh -f /etc/frr/eigrpd.conf
```

To show learned routes:

```bash
vtysh -c "show ip route"
```

## Get linux hosts IP addresses from IOS DHCP servers

```bash
cat << EOF > dhcpleases.yaml
- hosts: distribution
  gather_facts: no
  tasks:
    - ios_command:
        commands:
          - show ip dhcp binding
      register: output
    - set_fact:
        ip_list: "{{ output.stdout | regex_findall('[0-9]{1,3}\\\.[0-9]{1,3}\\\.[0-9]{1,3}\\\.[0-9]{1,3}') | list }}"
    - debug:
        msg: "{{ item }}"
      loop: "{{ ip_list }}"
      delegate_to: 127.0.0.1
    - lineinfile:
        line: "{{ item }},"
        dest: ./linuxhosts
        create: yes
        state: present
      loop: "{{ ip_list }}"
      delegate_to: 127.0.0.1
EOF

ansible-playbook dhcpleases.yaml

ansible -i "$(cat linuxhosts)" -u root -e ansible_password=testtest -m ping all
```

## Configure RHEL hosts with rhel-system-roles

```bash
yum -y install rhel-system-roles

export ANSIBLE_ROLES_PATH=./roles:/usr/share/ansible/roles 

export ANSIBLE_ROLES_PATH=./roles:/usr/share/ansible/roles >> $HOME/.bashrc

cat << EOF > ./configure_rhel_ntp.yaml
- hosts: all
  vars:
    timesync_ntp_servers:
      - hostname: 192.168.1.1
        pool: yes
        iburst: yes
    timesync_ntp_provider: ntp
  roles:
    - role: rhel-system-roles.timesync
  tasks:
    - package:
        name:
          - ntp-perl
EOF

ansible-playbook -i "$(cat linuxhosts)" -u root -e ansible_password=testtest configure_rhel_ntp.yaml
```
