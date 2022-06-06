#!/usr/bin/env python

ANSIBLE_METADATA = {
    "metadata_version": "1.1",
    "status": ["preview"],
    "supported_by": "community",
}

DOCUMENTATION = """
---
module: telnetos
short_description: Deploys boiler plate config over telnet server
version_added: '2.8'
description:
    - 'Deploys boiler plate config over telnet server'
requirements: [ gns3fy ]
author:
    - David Flores (@netpanda)
options:
    remote_addr:
        description:
            - Remote Address to perform the telnet connection
        required: true
        type: str
    port:
        description:
            - Telnet port to connect to device console
        type: int
        required: true
    login_prompt:
        description:
            - List of possible prompt(s) when login to remote device
        type: list
    password:
        description:
            - Password string to log into the device
        type: str
    send_newline:
        description:
            - To send a newline character before attempting to get prompt
        default: false
        type: bool
    prompts:
        description:
            - List of prompts expected before sending next command. Can be regexes
        type: list
        default: ['[#>$]']
    timeout:
        description:
            - Timeout of the session or the expected prompt
        type: int
        default: 30
    command:
        description:
            - List of commands to be executed in the sessions.
        type: list
        required: true
    pause:
        description:
            - Delay in seconds between commands sent
        type: int
        default: 1
    user:
        description:
            - User to login with device
        type: str
    root_set_user_prompts:
        description:
            - List of prompts to expect when you need to set root user on device
        type: list
    root_set_password_prompts:
        description:
            - List of prompts to expect when you need to set root password on device
        type: list
    pre_login_actions:
        description:
            - Special actions to be performed before login to device
        type: str
        choices: ['reboot_node']
    post_login_actions:
        description:
            - Special actions to be performed after login to device
        type: str
        choices: ['eos_disable_ztp', 'junos_enter_cli', 'xr_wait_system']
    gns3fy_data:
        description:
            - Data specs used in gns3fy to perform actions on devices. Mainly pre_login
        type: dict
"""

EXAMPLES = """
# Retrieve the GNS3 server version
- name: Send the initial commands to the device
  telnetos:
    url: http://localhost
    port: 3080
  register: result
- debug: var=result
"""

RETURN = """
cmd:
    description: Arguments passed
    type: list
stdout:
    description: Stdout message
    type: str
changed:
    description: If an action was executed
    type: bool
"""
import time          # noqa: E402
import traceback     # noqa: E402

PEXPECT_IMP_ERR = None
try:
    import pexpect

    HAS_PEXPECT = True
except ImportError:
    PEXPECT_IMP_ERR = traceback.format_exc()
    HAS_PEXPECT = False

from ansible.module_utils.basic import AnsibleModule, missing_required_lib  # noqa: E402
from ansible.errors import AnsibleError                                     # noqa: E402

GNS3FY_IMP_ERR = None
try:
    from gns3fy import Gns3Connector, Project

    HAS_GNS3FY = True
except ImportError:
    GNS3FY_IMP_ERR = traceback.format_exc()
    HAS_GNS3FY = False

TIMEOUTS = {
    "pre_login": 30,
    "post_login": 30,
    "config_dialog": 30,
    "login_prompt": 30,
    "general": 30,
}


def enable_prompt_resolve(conn, enable_password, prompts):
    try:
        conn.sendline("enable")
        i = conn.expect(["[pP]assword:", *prompts])
        if i == 0:
            conn.sendline(enable_password)
            conn.expect(prompts)
    except pexpect.EOF:
        raise AnsibleError(f"on enable_prompt_resolve  enable EOF: {conn.before}")
    except pexpect.TIMEOUT:
        raise AnsibleError(f"on enable_prompt_resolve TIMEOUT: {conn.before}")


def login_prompt_resolve(
    conn,
    login_prompts,
    user,
    password,
    enable_password,
    prompts,
    timeout=30,
    use_prompts=True,
):
    try:
        if use_prompts:
            y = conn.expect([*login_prompts, *prompts], timeout=timeout)
        else:
            y = conn.expect(login_prompts, timeout=timeout)
        if y == 0:
            conn.sendline(user)
            i = conn.expect(["[pP]assword:", ">", *prompts], timeout=timeout)
            if i == 0:
                conn.sendline(password)
                sub_i = conn.expect([">", *prompts], timeout=timeout)
                if sub_i == 0:
                    enable_prompt_resolve(conn, enable_password, prompts)
            elif i == 1:
                enable_prompt_resolve(conn, enable_password, prompts)
        elif y == 1:
            # Entering root user setup
            conn.sendline(user)
            i = conn.expect(["Enter root-system username:"])
    except pexpect.EOF:
        raise AnsibleError(f"on login_prompt_resolve  enable EOF: {conn.before}")
    except pexpect.TIMEOUT:
        raise AnsibleError(f"on login_prompt_resolve TIMEOUT: {conn.before}")


def set_missing_timeouts(timeout_dict):
    general = timeout_dict.get("general")
    if not general:
        general = [v for k, v in timeout_dict.items() if v][0]
    if not general:
        return TIMEOUTS
    for key in TIMEOUTS.keys():
        if key not in timeout_dict.keys():
            timeout_dict[key] = TIMEOUTS[key]
    return timeout_dict


def main():
    module = AnsibleModule(
        argument_spec=dict(
            remote_addr=dict(type="str", required=True),
            port=dict(type="int", required=True),
            login_prompt=dict(type="list", default=None),
            user=dict(type="str", default=None),
            password=dict(type="str", default=None, no_log=True),
            enable_password=dict(type="str", default="", no_log=True),
            send_newline=dict(type="bool", default=False),
            prompts=dict(type="list", default=["[#$]"]),
            root_set_user_prompts=dict(type="list", default=None),
            root_set_password_prompts=dict(type="list", default=None, no_log=True),
            config_dialog=dict(type="bool", default=False),
            timeout=dict(type="dict", default=TIMEOUTS),
            command=dict(type="list", required=True),
            pause=dict(type="int", default=1),
            pre_login_action=dict(
                type="str",
                choices=["xr9k_reboot_node", "nxos9k_disable_poap"],
                default=None,
            ),
            post_login_action=dict(
                type="str",
                choices=["eos_disable_ztp", "junos_enter_cli", "xr_wait_system"],
                default=None,
            ),
            gns3fy_data=dict(type="dict", default=None),
        )
    )

    if not HAS_PEXPECT:
        module.fail_json(msg=missing_required_lib("pexpect"), exception=PEXPECT_IMP_ERR)

    result = dict(changed=False)

    remote_addr = module.params["remote_addr"]
    port = module.params["port"]
    login_prompt = module.params["login_prompt"]
    user = module.params["user"]
    password = module.params["password"]
    enable_password = module.params["enable_password"]
    send_newline = module.params["send_newline"]
    prompts = module.params["prompts"]
    root_set_user_prompts = module.params["root_set_user_prompts"]
    root_set_password_prompts = module.params["root_set_password_prompts"]
    config_dialog = module.params["config_dialog"]
    timeout = set_missing_timeouts(module.params["timeout"])
    command = module.params["command"]
    pause = module.params["pause"]
    pre_login_action = module.params["pre_login_action"]
    post_login_action = module.params["post_login_action"]
    gns3fy_data = module.params["gns3fy_data"]

    conn = pexpect.spawn(
        f"telnet {remote_addr} {port}",
        timeout=timeout["general"],
        maxread=4092,
        encoding="utf-8",
        searchwindowsize=2000,
        ignore_sighup=True,
    )

    # Sends newline at the beginning of the connections
    if send_newline:
        conn.sendline("\r")

    # Pre-login actions: Depends on the platform and image, for example it can be to
    # reboot the node or disable POAP
    if pre_login_action:

        # NXOS 9K Disable POAP
        if pre_login_action == "nxos9k_disable_poap":
            try:
                # TODO: around 60
                conn.expect(
                    ["Starting Auto Provisioning", pexpect.TIMEOUT],
                    timeout=timeout["pre_login"],
                )
                conn.sendline("\r")
                conn.expect(["Abort Power On Auto Provisioning"])
                conn.sendline("yes")
                conn.expect(["Do you want to enforce secure password standard"])
                conn.sendline("no")
            except pexpect.EOF:
                raise AnsibleError(f"on nxos9k_disable_poap EOF: {conn.before}")
            except pexpect.TIMEOUT:
                raise AnsibleError(f"on nxos9k_disable_poap TIMEOUT: {conn.before}")

        # XR 9K Reboot node first
        elif pre_login_action == "xr9k_reboot_node":
            if not HAS_GNS3FY:
                module.fail_json(
                    msg=missing_required_lib("gns3fy"), exception=GNS3FY_IMP_ERR
                )
            server = Gns3Connector(
                url=f"{gns3fy_data['url']}:{gns3fy_data.get('port', 3080)}"
            )
            lab = Project(name=gns3fy_data.get("project_name"), connector=server)
            lab.get()
            node = lab.get_node(gns3fy_data.get("node_name"))
            try:
                # TODO: around 60
                conn.expect(["reboot: Restarting"], timeout=timeout["pre_login"])
                node.stop()
                node.start()
            except pexpect.EOF:
                raise AnsibleError(f"on xr9k_reboot_node EOF: {conn.before}")
            except pexpect.TIMEOUT:
                node.stop()
                node.start()
            time.sleep(10)
            # TODO: around 30
            i = conn.expect(
                ["Cisco IOS XR console", pexpect.EOF, pexpect.TIMEOUT],
                timeout=timeout["pre_login"],
            )
            if i == 0:
                conn.sendline("\r")
            elif i == 1:
                try:
                    # TODO: around 30
                    conn.expect(root_set_user_prompts, timeout=timeout["pre_login"])
                except pexpect.EOF:
                    conn.close(force=True)
                    # TODO: Set as general timeout (which should be high)
                    conn = pexpect.spawn(
                        f"telnet {remote_addr} {port}",
                        timeout=timeout["general"],
                        maxread=4092,
                        encoding="utf-8",
                        searchwindowsize=2000,
                        ignore_sighup=True,
                    )
                    # Pause to send command after device initialization
                    time.sleep(360)
                    conn.sendline("\r")
                    conn.sendline("\r")
                except pexpect.TIMEOUT:
                    conn.sendline("\r")

    # Root user section
    if root_set_user_prompts:
        try:
            conn.expect(root_set_user_prompts)
            conn.sendline(user)
        except pexpect.EOF:
            raise AnsibleError(f"on root_set_user_prompts EOF: {conn.before}")
        except pexpect.TIMEOUT:
            raise AnsibleError(f"on root_set_user_prompts TIMEOUT: {conn.before}")
    if root_set_password_prompts:
        while True:
            try:
                conn.expect(root_set_password_prompts, timeout=5)
                conn.sendline(password)
            except pexpect.EOF:
                raise AnsibleError(f"on root_set_password_prompts EOF: {conn.before}")
            except pexpect.TIMEOUT:
                time.sleep(pause)
                conn.sendline("\r")
                break

    # Configuration Dialog section
    if config_dialog:
        # TODO: Was set as general timeout
        i = conn.expect(
            ["[bB]asic|initial [cC]onfiguration [dD]ialog", pexpect.TIMEOUT],
            timeout=timeout["config_dialog"],
        )
        if i == 0:
            conn.sendline("no")
            time.sleep(pause)
        # TODO: Was set as general timeout
        i = conn.expect(
            ["terminate autoinstall?", pexpect.TIMEOUT],
            timeout=timeout["config_dialog"],
        )
        if i == 0:
            conn.sendline("yes")
            time.sleep(pause)
        conn.sendline("\r")

    # Main login prompt section
    if login_prompt:
        # TODO: Was set as general timeout
        login_prompt_resolve(
            conn,
            login_prompt,
            user,
            password,
            enable_password,
            prompts,
            timeout=timeout["login_prompt"],
        )

    # Post-login actions: Depends on the platform and image, for example it can be to
    # disable ZTP, enter CLI prompt or just wait for system initialization
    if post_login_action:
        if post_login_action == "eos_disable_ztp":
            conn.sendline("\r")
            i = conn.expect([">", *prompts])
            if i == 0:
                enable_prompt_resolve(conn, enable_password, prompts)
            conn.sendline("zerotouch disable")
            time.sleep(pause)
            conn.sendline("wr mem")
            time.sleep(pause)
            conn.sendline("reload force")
            # TODO: Was set to 240
            login_prompt_resolve(
                conn,
                login_prompt,
                user,
                password,
                enable_password,
                prompts,
                timeout=timeout["general"],
                use_prompts=False,
            )
        elif post_login_action == "junos_enter_cli":
            conn.sendline("\r")
            i = conn.expect(["%", *prompts])
            if i == 0:
                conn.sendline("cli")
                time.sleep(pause)
        elif post_login_action == "xr_wait_system":
            conn.sendline("\r")
            time.sleep(pause)
            # TODO: Was set to 60
            i = conn.expect(
                ["SYSTEM CONFIGURATION COMPLETED", pexpect.EOF, pexpect.TIMEOUT],
                timeout=timeout["post_login"],
            )
            if i == 0:
                conn.sendline("\r")

    # Commands push
    for comm in command:
        for prompt in prompts:
            try:
                conn.sendline("\r")
                time.sleep(pause)
                conn.expect(prompt)
                conn.sendline(comm)
                time.sleep(pause)
                result["changed"] = True
            except pexpect.EOF:
                raise AnsibleError(f"on commands  enable EOF: {conn.before}")
            except pexpect.TIMEOUT:
                raise AnsibleError(f"on commands TIMEOUT: {conn.before}")

    conn.close()

    result.update(stdout=conn.before)
    module.exit_json(**result)


if __name__ == "__main__":
    main()
