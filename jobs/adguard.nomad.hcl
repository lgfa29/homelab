job "adguard" {
  group "adguard" {
    restart {
      attempts = 15
      delay    = "3s"
      mode     = "delay"
    }

    network {
      port "dns" {
        to = 53
      }
      port "http" {
        to = 3000
      }
    }

    service {
      provider = "nomad"
      name     = "adguard"
      port     = "dns"

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "5s"
      }
    }

    service {
      provider = "nomad"
      name     = "adguard-ui"
      port     = "http"
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
      type            = "csi"
      source          = "adguard-conf"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    volume "work" {
      type            = "csi"
      source          = "adguard-work"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "adguard" {
      driver = "docker"

      config {
        image = "adguard/adguardhome:v0.107.69"
        ports = ["dns", "http"]
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
