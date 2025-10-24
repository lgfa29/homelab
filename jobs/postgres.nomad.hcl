job "postgres" {
  group "postgres" {
    network {
      port "pg" {
        to = 5432
      }
    }

    volume "postgres" {
      type   = "host"
      source = "postgres"
    }

    service {
      provider = "nomad"
      name     = "postgres"
      port     = "pg"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.pg.rule=HostSNI(`*`)",
        "traefik.tcp.routers.pg.entrypoints=pg",
      ]

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "10s"
      }
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "postgres:18.0"
        ports = ["pg"]
      }

      resources {
        cpu    = 1024
        memory = 4096
      }

      env {
        PGDATA = "${NOMAD_TASK_DIR}/postgresql/18/docker"
      }

      volume_mount {
        volume      = "postgres"
        destination = "${NOMAD_TASK_DIR}/postgresql"
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env"
        env         = true
        data        = <<EOF
{{with nomadVar "nomad/jobs/postgres" -}}
POSTGRES_PASSWORD={{.root_password}}
POSTGRES_USER=postgres
{{end -}}
EOF
      }
    }
  }
}
