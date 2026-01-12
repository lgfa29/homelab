job "grafana" {
  group "grafana" {
    restart {
      attempts = 15
      delay    = "3s"
      mode     = "delay"
    }

    network {
      port "http" {
        to = 3000
      }
    }

    service {
      provider = "nomad"
      name     = "grafana"
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.grafana.rule=Host(`grafana.feijuca.fun`)",
      ]

      check {
        type     = "http"
        timeout  = "1s"
        interval = "5s"
        path     = "/api/health"
      }
    }

    volume "grafana" {
      type            = "csi"
      source          = "grafana"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:12.4.0-20836657505-ubuntu"
        ports = ["http"]
        dns_servers = [
          "192.168.1.32",
          "192.168.1.33",
          "192.168.1.42",
        ]
      }

      volume_mount {
        volume      = "grafana"
        destination = "/var/lib/grafana"
      }
    }
  }
}
