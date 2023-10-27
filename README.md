## Ansible-axiom

This is the guide for deploy AxiomLedger nodes and execute chaosTests using Ansible. It is recommended to first install Ansible on your local machine before proceeding. **NOTE**: Instructions for deploying and using ansible can be found [here](https://github.com/ansible/ansible)

## Usage

#### Clone project

AxiomLedger start script relies on already compiled binaries. Please install or build AxiomLedger on target machine before starting.
Use commands below to clone the project:
`git clone git@github.com:axiomesh/ansible-axiom.git`

#### Configure basic items

1. Specify the configuration file path as ansible.cfg,use the following command to set:
   `export ANSIBLE_CONFIG="./ansible.cfg" `
   you can verify the configuration file path by running the command `ansible --version`. The inventory/hosts and logs specified in `ansible.cfg` default located in the current directory.

```
[defaults]
# (boolean) By default Ansible will issue a warning when received from a task action (module or action plugin)
# These warnings can be silenced by adjusting this setting to False.
;action_warnings=True

# (pathlist) Comma separated list of Ansible inventory sources
inventory=./inventory/hosts

# (path) File to which Ansible will log on the controller. When empty logging is disabled.
log_path=./logs/ansible.log

# (boolean) Set this to "False" if you want to avoid host key checking by the underlying tools Ansible uses to connect to the host
host_key_checking=False
```

2. Modify the host configuration in `inventory/hosts`. For first time use, you can use the localhost ip group.

3. Modify the `file/x.sh`, fill in the project path and binary path of axiom-ledger. Check the `control_solo/start_solo.yml`, confirm the IP address and execution directory of the target machine.

4. Execute the script using the ansible-playbook command and check the results: `ansible-playbook control_solo/start_solo.yml`

**Noting**: Make sure to review the results after each step. If you encounter any issues, provide more detailed information for further assistance.
