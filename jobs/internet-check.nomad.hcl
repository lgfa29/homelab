job "internet-check" {
  group "ping" {
    network {
      port "http" {}
    }

    service {
      provider = "nomad"
      name     = "ping"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.ping.rule=Host(`ping.feijuca.fun`)",
      ]
    }

    task "ping" {
      driver = "docker"

      config {
        image = "prom/blackbox-exporter:v0.27.0"
        ports = ["http"]
        args = [
          "--web.listen-address=0.0.0.0:${NOMAD_PORT_http}",
          "--config.file=${NOMAD_TASK_DIR}/blackbox.yaml",
        ]
      }

      template {
        destination   = "${NOMAD_TASK_DIR}/blackbox.yaml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = <<EOF
modules:
  http_2xx:
    prober: http
EOF
      }
    }
  }
}
