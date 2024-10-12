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

provider "consul" {
  address = "server.feijuca.consul:8501"
  scheme  = "https"
}

provider "nomad" {
  address = "https://nomad.service.consul:4646"
}
