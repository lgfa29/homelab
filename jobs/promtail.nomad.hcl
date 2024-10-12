job "promtail" {
  datacenters = ["*"]
  type        = "system"
  node_pool   = "all"

  group "promtail" {
    restart {
      attempts = 10
      delay    = "10s"
      mode     = "delay"
    }

    network {
      port "http" {}
    }

    service {
      name = "promtail"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.promtail.rule=Host(`promtail.feijuca.fun`)",
      ]

      check {
        type     = "http"
        path     = "/ready"
        interval = "5s"
        timeout  = "1s"
      }
    }

    task "promtail" {
      driver = "docker"

      config {
        image = "grafana/promtail:2.7.4"
        args  = ["-config.file=${NOMAD_TASK_DIR}/config/promtail-config.yaml"]
        ports = ["http"]

        mount {
          type   = "bind"
          target = "/var/log"
          source = "/var/log"
        }

        mount {
          type     = "bind"
          target   = "/opt/nomad/data/alloc"
          source   = "/opt/nomad/data/alloc"
          readonly = true
        }
      }

      template {
        data = <<EOF
server:
  http_listen_port: {{env "NOMAD_PORT_http"}}

positions:
  filename: /var/log/positions.yaml

clients:
{{- range service "loki"}}
  - url: http://{{.Address}}:{{.Port}}/loki/api/v1/push
{{- end}}

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          node: {{env "node.unique.name"}}
          __path__: /var/log/*log
  - job_name: nomad-allocs
    static_configs:
      - targets:
          - localhost
        labels:
          job: allocs
          node: {{env "node.unique.name"}}
          __path__: /opt/nomad/data/alloc/**/logs/*
          __path_exclude__: /opt/nomad/data/alloc/**/logs/*.fifo
    pipeline_stages:
    - match:
        selector: '{job="allocs"}'
        stages:
          - regex:
              source: filename
              expression: "/opt/nomad/data/alloc/(?P<alloc>\\S+?)/alloc/logs/(?P<task>\\S+?)\\..*"
          - labels:
              alloc:
              task:
EOF

        destination = "${NOMAD_TASK_DIR}/config/promtail-config.yaml"
      }
    }
  }
}
