resource "ansible_group" "servers" {
  name = "servers"

  children = [
    ansible_group.feijuca_servers.name,
  ]
}

resource "ansible_group" "clients" {
  name = "clients"

  children = [
    ansible_group.feijuca_clients.name,
  ]
}

# Feijuca cluster.
resource "ansible_group" "feijuca" {
  name = "feijuca"

  children = [
    ansible_group.feijuca_servers.name,
    ansible_group.feijuca_clients.name,
  ]
}

resource "ansible_group" "feijuca_servers" {
  name = "feijuca_servers"

  children = [
    ansible_group.proxmox_servers.name,
    ansible_group.rk1_servers.name,
  ]
}

resource "ansible_group" "feijuca_clients" {
  name = "feijuca_clients"

  children = [
    ansible_group.proxmox_clients.name,
    ansible_group.rk1_clients.name,
    ansible_group.vila_clients.name,
  ]
}

# Proxmox instances.
resource "ansible_group" "proxmox" {
  name = "proxmox"

  children = [
    ansible_group.proxmox_servers.name,
    ansible_group.proxmox_clients.name
  ]
}

resource "ansible_group" "proxmox_servers" {
  name = "proxmox_servers"
}

resource "ansible_group" "proxmox_clients" {
  name = "proxmox_clients"
}

resource "ansible_host" "nomad_servers" {
  for_each = local.nomad_servers

  name   = "px-${each.value.name}"
  groups = [ansible_group.proxmox_servers.name]

  variables = {
    ansible_host = local.nomad_servers_ip[each.key]
  }
}

resource "ansible_host" "px_nomad_client_1" {
  name   = "px-nomad-client-1"
  groups = [ansible_group.proxmox_clients.name]

  variables = {
    ansible_host = "192.168.1.42"
  }
}

# RK1 instances.
locals {
  rk1_instances = {
    rk1_1 = {
      name   = "rk1-1"
      ip     = "192.168.1.31"
      groups = [ansible_group.rk1_servers.name]
    },
    rk1_2 = {
      name   = "rk1-2"
      ip     = "192.168.1.32"
      groups = [ansible_group.rk1_clients.name]
    },
    rk1_3 = {
      name   = "rk1-3"
      ip     = "192.168.1.33"
      groups = [ansible_group.rk1_clients.name]
    },
    rk1_4 = {
      name   = "rk1-4"
      ip     = "192.168.1.34"
      groups = [ansible_group.rk1_clients.name]
    },
  }
}

resource "ansible_group" "rk1" {
  name = "rk1"

  children = [
    ansible_group.rk1_servers.name,
    ansible_group.rk1_clients.name
  ]
}

resource "ansible_group" "rk1_servers" {
  name = "rk1_servers"
}

resource "ansible_group" "rk1_clients" {
  name = "rk1_clients"
}

resource "ansible_host" "rk1_instances" {
  for_each = local.rk1_instances

  name   = each.value.name
  groups = each.value.groups

  variables = {
    ansible_host = each.value.ip
  }
}

# Vila.
locals {
  vila_instances = {
    vila_rpi4_1 = {
      name   = "vila-rpi4-1"
      ip     = "100.101.210.98"
      groups = [ansible_group.vila_clients.name]
    }
  }
}

resource "ansible_group" "vila" {
  name = "vila"

  children = [
    ansible_group.vila_clients.name,
  ]
}

resource "ansible_group" "vila_clients" {
  name = "vila_clients"
}

resource "ansible_host" "vila_rpi4" {
  for_each = local.vila_instances

  name   = each.value.name
  groups = each.value.groups

  variables = {
    ansible_host = each.value.ip
  }
}
