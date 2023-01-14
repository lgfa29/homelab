# Ansible

[Ansible](https://www.ansible.com/) is used to configure all machines after
they have been provisioned. It is expected that the user is able to SSH into
the target machines.

## Running

Running everything:

```console
$ ansible-playbook cluster.yml
```

Configuring specific groups:

```console
$ ansible-playbook servers.yml
$ ansible-playbook clients.yml
```

Configuring specific tool:

```console
$ ansible-playbook --tags nomad clients.yml
$ ansible-playbook --tags tool servers.yml
$ ansible-playbook --tags runtime servers.yml
```

## Playbooks

There are three main playbooks:

  - `clients.yml` is used to configure Nomad and Consul clients.
  - `servers.yml` is used to configure Nomad and Consul servers.
  - `cluster.yml` is used to run both the `clients.yml` and `server.yml`
    playbooks.

The `hostname.yml` playbook is used to set a machine's hostname. I don't
remember why I needed it but :shrug:.

`hosts.ini` is the hosts file and groups them into clients and servers.

`group_vars` and `host_vars` defines values specific to groups and hosts.

## Roles

- [`cni_plugins`](./roles/cni_plugins)
- [`common`](./roles/common)
- [`consul`](./roles/consul)
- [`hashicorp_tool`](./roles/hashicorp_tool)
- [`nomad`](./roles/nomad)
