terraform {
  required_version = ">=0.14"

  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "2.16.2"
    }
  }
}

provider "consul" {
  address = "server.feijuca.consul:8501"
  scheme  = "https"
}
