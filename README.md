这是使用 ansible 安装 AxiomLedger 节点的操作指南，在使用之前建议先在本地安装 ansible.接下来将给出具体的使用步骤：

第一步，指定配置文件路径为仓库根目录下的 ansible.cfg:
`export ANSIBLE_CONFIG="./ansible.cfg"`，设置后可以通过 `ansible --version`查看配置文件的路径；
**_注意_**：配置文件中默认指定的 inventory/hosts 和 logs 也在当前目录下。

第二步：通过`ansible-playbook`命令执行脚本，并检查结果：
`ansible-playbook 02_start_solo.yml`
