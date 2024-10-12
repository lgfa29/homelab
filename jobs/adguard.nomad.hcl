locals {
  adguard_image = "adguard/adguardhome:v0.107.45"
}

job "adguard" {
  node_pool = "storage"

  group "adguard" {
    restart {
      attempts = 15
      delay    = "3s"
    }

    network {
      dns {
        servers = ["192.168.0.1"]
      }

      port "dns" {
        to = 53
      }
      port "ui" {
        to = "3000"
      }
    }

    service {
      name = "adguard"
      port = "dns"
      tags = ["dns"]
    }

    service {
      name = "adguard-ui"
      port = "ui"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.adguard.rule=Host(`adguard.feijuca.fun`)",
      ]

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "5s"
      }
    }

    volume "conf" {
      type   = "host"
      source = "adguard-conf"
    }

    volume "work" {
      type   = "host"
      source = "adguard-work"
    }

    task "adguard" {
      driver = "docker"

      config {
        image = local.adguard_image
        ports = ["dns", "ui"]
      }

      resources {
        cpu    = 100
        memory = 1024
      }

      volume_mount {
        volume      = "conf"
        destination = "/opt/adguardhome/conf"
      }

      volume_mount {
        volume      = "work"
        destination = "/opt/adguardhome/work"
      }
    }
  }
}
