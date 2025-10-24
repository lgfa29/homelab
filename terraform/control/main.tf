terraform {
  required_version = ">=0.14"

  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.1.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.1"
    }
  }

  backend "s3" {
    bucket       = "feijuca-homelab"
    key          = "terraform/homelab"
    region       = "ca-central-1"
    use_lockfile = true
  }
}

provider "nomad" {
  address = "http://192.168.1.31:4646"
}

provider "proxmox" {
  endpoint = "https://192.168.1.11:8006"
  username = "terraform@pve"
  insecure = true

  ssh {
    agent    = true
    username = "root"
  }
}
