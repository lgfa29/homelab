job "registry" {
  node_pool = "storage"

  group "registry" {
    network {
      port "http" {
        static = "5000"
      }
    }

    service {
      provider = "nomad"
      name     = "registry"
      port     = "http"

      check {
        type     = "http"
        path     = "/v2/"
        timeout  = "1s"
        interval = "5s"
      }
    }

    volume "registry" {
      type   = "host"
      source = "registry"
    }

    task "registry" {
      driver = "docker"

      config {
        image      = "registry:2"
        force_pull = false
        ports      = ["http"]

        volumes = [
          "${NOMAD_TASK_DIR}/config.yaml:/etc/distribution/config.yml",
        ]
      }

      template {
        destination = "${NOMAD_TASK_DIR}/config.yaml"
        data        = <<EOF
version: 0.1
log:
  level: "debug"
storage:
  filesystem:
    rootdirectory: /var/lib/registry
EOF
      }

      volume_mount {
        volume      = "registry"
        destination = "/var/lib/registry"
      }
    }
  }
}
