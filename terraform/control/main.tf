terraform {
  required_version = ">=0.14"

  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "2.16.2"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.1.0"
    }
  }
}

provider "nomad" {
  address = "http://192.168.1.31:4646"
}
