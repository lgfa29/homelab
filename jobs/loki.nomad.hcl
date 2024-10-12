job "loki" {
  datacenters = ["dc1"]
  node_pool   = "storage"

  group "loki" {
    network {
      port "http" {}
    }

    service {
      name = "loki"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.loki.rule=Host(`loki.feijuca.fun`)",
      ]

      check {
        type     = "http"
        path     = "/ready"
        interval = "5s"
        timeout  = "1s"
      }
    }

    volume "loki" {
      type   = "host"
      source = "loki"
    }

    task "loki" {
      driver = "docker"
      user   = "root"

      config {
        image = "grafana/loki:2.7.4"
        args  = ["-config.file=${NOMAD_TASK_DIR}/config/loki-config.yaml"]
        ports = ["http"]
      }

      template {
        data        = <<EOF
auth_enabled: false

server:
  http_listen_port: {{env "NOMAD_PORT_http"}}

common:
  path_prefix: /tmp/loki
  storage:
    filesystem:
      chunks_directory: /var/lib/loki/chunks
      rules_directory: /var/lib/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

limits_config:
  per_stream_rate_limit: 512M
  per_stream_rate_limit_burst: 1024M
  ingestion_burst_size_mb: 1000
  ingestion_rate_mb: 10000

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2023-04-01
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

#ruler:
#  alertmanager_url: http://localhost:9093

analytics:
  reporting_enabled: false
EOF
        destination = "${NOMAD_TASK_DIR}/config/loki-config.yaml"
      }

      resources {
        cpu    = 100
        memory = 512
      }

      volume_mount {
        volume      = "loki"
        destination = "/var/lib/loki"
      }
    }
  }
}
