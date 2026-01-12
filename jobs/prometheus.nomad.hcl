job "prometheus" {
  group "prometheus" {
    restart {
      attempts = 15
      delay    = "3s"
      mode     = "delay"
    }

    network {
      port "http" {}
    }

    service {
      provider = "nomad"
      name     = "prometheus"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.prom.rule=Host(`prom.feijuca.fun`)",
      ]
    }

    volume "prometheus" {
      type   = "host"
      source = "prometheus"
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v3.7.3"
        ports = ["http"]
        args = [
          "--config.file=${NOMAD_TASK_DIR}/prometheus.yaml",
          "--storage.tsdb.path=/prometheus",
          "--web.listen-address=0.0.0.0:${NOMAD_PORT_http}",
        ]
      }

      resources {
        cpu    = 100
        memory = 256
      }

      template {
        destination   = "${NOMAD_TASK_DIR}/prometheus.yaml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = <<EOF
---
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s

scrape_configs:
{{- range $svc := sprig_list "ping" "ping-vila"}}
{{- range nomadService 1 (env "NOMAD_ALLOC_ID") $svc}}
  - job_name: '{{$svc}}'
    metrics_path: /probe
    scrape_interval: 1m
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - https://ismyinternetworking.com
        - https://globo.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: {{.Address}}:{{.Port}}
{{- end}}
{{- end}}

{{- range nomadService 1 (env "NOMAD_ALLOC_ID") "nut-metrics"}}
  - job_name: "nut"
    static_configs:
      - targets:
      {{- range nomadService "nut" }}
          - {{.Address}}:{{.Port}}
      {{- end }}
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: {{.Address}}:{{.Port}}
{{- end}}

{{- range $svc := sprig_list "master" "volumes" "filer"}}
  - job_name: "seaweedfs-{{$svc}}"
    static_configs:
      - targets:
      {{- range nomadService (printf "seaweedfs-%s-metrics" $svc)}}
          - {{.Address}}:{{.Port}}
      {{- end }}
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
{{- end }}
EOF
      }

      volume_mount {
        volume      = "prometheus"
        destination = "/prometheus"
      }
    }
  }
}
