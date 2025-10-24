locals {
  px_node_name = "torresmo"
  px_datastore = "local"

  authorized_keys = compact(split("\n", data.http.ssh_public_keys.response_body))

  nomad_servers = {
    nomad_server_1 = {
      name = "nomad-server-1"
    },
    nomad_server_2 = {
      name = "nomad-server-2"
    },
  }

  nomad_servers_ip = {
    for k, v in proxmox_virtual_environment_vm.nomad_servers :
    k => one(v.ipv4_addresses[1])
  }
}

data "http" "ssh_public_keys" {
  url = "https://github.com/lgfa29.keys"
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  url          = "https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img"
  file_name    = "noble-server-cloudimg-amd64.qcow2"
  node_name    = local.px_node_name
  datastore_id = local.px_datastore
  content_type = "import"
}

data "cloudinit_config" "ubuntu" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = <<EOF
users:
  - name: "laoqui"
    groups:
      - "sudo"
    shell: "/bin/bash"
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    ssh_authorized_keys:
      ${indent(6, yamlencode(local.authorized_keys))}
package_update: true
packages:
  - "qemu-guest-agent"
runcmd:
  - "systemctl enable qemu-guest-agent"
  - "systemctl start qemu-guest-agent"
EOF
  }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  node_name    = local.px_node_name
  datastore_id = local.px_datastore

  source_raw {
    data      = data.cloudinit_config.ubuntu.rendered
    file_name = "ubuntu-user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "nomad_servers" {
  for_each = local.nomad_servers

  name      = each.value.name
  node_name = local.px_node_name

  agent {
    enabled = true
  }

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 8 * 1024
  }

  disk {
    datastore_id = "ssd"
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 50
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id      = "local-zfs"
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.nomad_servers_metadata[each.key].id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge   = "vmbr1"
    firewall = true
  }
}

resource "proxmox_virtual_environment_file" "nomad_servers_metadata" {
  for_each = local.nomad_servers

  content_type = "snippets"
  node_name    = local.px_node_name
  datastore_id = local.px_datastore

  source_raw {
    data      = <<EOF
#cloud-config
local-hostname: "${each.value.name}"
EOF
    file_name = "${each.value.name}-cloud-config-metadata.yaml"
  }
}

output "vm_ip" {
  value = local.nomad_servers_ip
}
