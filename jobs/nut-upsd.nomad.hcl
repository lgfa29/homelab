job "nut-upsd" {
  group "nut-upsd" {
    constraint {
      attribute = attr.unique.hostname
      value     = "px-nomad-client-1"
    }

    network {
      port "nut" {
        to = 3493
      }
    }

    service {
      provider = "nomad"
      name     = "nut"
      port     = "nut"

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "5s"
      }
    }

    task "upsd" {
      driver = "docker"

      config {
        image      = "instantlinux/nut-upsd:2.8.3-r3"
        privileged = true
        ports      = ["nut"]
      }

      env {
        API_PASSWORD = "pass"
        MAXAGE       = "30"
        SERIAL       = "GA5MS2000035"
      }
    }
  }

  group "prom-exporter" {
    network {
      port "exporter" {}
    }

    service {
      provider = "nomad"
      name     = "nut-metrics"
      port     = "exporter"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.nut-metrics.rule=Host(`nut-metrics.feijuca.fun`)",
      ]

      check {
        type     = "http"
        timeout  = "1s"
        interval = "5s"
        path     = "/"
      }
    }

    task "prom-exporter" {
      driver = "docker"

      config {
        image = "hon95/prometheus-nut-exporter:1"
        ports = ["exporter"]
      }

      env {
        TZ           = "America/Toronto"
        HTTP_PATH    = "/metrics"
        HTTP_ADDRESS = "0.0.0.0"
        HTTP_PORT    = NOMAD_PORT_exporter
      }
    }
  }
}
