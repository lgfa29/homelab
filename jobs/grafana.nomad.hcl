job "grafana" {
  datacenters = ["dc1"]

  group "grafana" {
    network {
      port "http" {
        to = 3000
      }
    }

    service {
      name = "grafana"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.grafana.rule=Host(`grafana.feijuca.fun`)",
      ]
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana-oss:9.4.7"
        ports = ["http"]
      }
    }
  }
}
