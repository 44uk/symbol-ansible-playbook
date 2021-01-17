# Ansible Playbook for Symbol Platform

- for `Ubuntu 20.04`


## Usage

You need to prepare some files / variables before execute it.


### Host inventory

Create and Edit `playbook/hosts`.

See `playbook/hosts.sample` for example.


### Host vars

Create and Edit `playbook/host_vars/{INVENTORY_HOSTNAME}.yml`.

See `playbook/host_vars/sample.yml` for example.


### Host custom preset

Create and Edit `playbook/files/{INVENTORY_HOSTNAME}/my-preset.yml`.

See `playbook/files/sample/my-preset.yml` for example.


## Run playbook

```shell
$ make remote-setup
```


### Vagrant

```shell
$ make recreate
$ make vm-setup
```
