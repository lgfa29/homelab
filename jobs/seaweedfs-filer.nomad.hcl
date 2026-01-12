job "seaweedfs-filer" {
  group "seaweedfs-filer" {
    count = 3

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    network {
      port "http" {}
      port "grpc" {}
      port "metrics" {}
    }

    service {
      provider = "nomad"
      name     = "seaweedfs-filer"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.filer.rule=Host(`filer.feijuca.fun`)",
      ]

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "10s"
      }
    }

    service {
      provider = "nomad"
      name     = "seaweedfs-filer-grpc"
      port     = "grpc"

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "10s"
      }
    }

    service {
      provider = "nomad"
      name     = "seaweedfs-filer-metrics"
      port     = "metrics"

      check {
        type     = "http"
        path     = "/metrics"
        method   = "HEAD"
        timeout  = "1s"
        interval = "10s"
      }
    }

    task "seaweedfs-filer" {
      driver = "docker"

      config {
        image = "chrislusf/seaweedfs:4.06"
        ports = ["http", "grpc", "metrics"]
        args = [
          "-config_dir", NOMAD_SECRETS_DIR,
          "filer",
          "-ip", NOMAD_IP_http,
          "-ip.bind", "0.0.0.0",
          "-master", SEAWEEDFS_MASTER,
          "-port", NOMAD_PORT_http,
          "-port.grpc", NOMAD_PORT_grpc,
          "-metricsPort", NOMAD_PORT_metrics,
        ]
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env"
        env         = true
        data        = <<EOF
{{- range $i, $s := nomadService "http-seaweedfs-master"}}
SEAWEEDFS_MASTER={{$s.Address}}:{{$s.Port}}.{{with nomadService "grpc-seaweedfs-master"}}{{with index . 0}}{{.Port}}{{end}}{{end}}
{{- end}}
EOF
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/filer.toml"
        data        = <<EOF
[filer.options]
recursive_delete = false

[postgres2]
enabled = true
createTable = """
  CREATE TABLE IF NOT EXISTS "%s" (
    dirhash   BIGINT,
    name      VARCHAR(65535),
    directory VARCHAR(65535),
    meta      bytea,
    PRIMARY KEY (dirhash, name)
  );
"""
{{range nomadService 1 (env "NOMAD_ALLOC_ID") "postgres" -}}
hostname = "{{.Address}}"
port = {{.Port}}
{{end -}}
{{with nomadVar "nomad/jobs/seaweedfs-filer" -}}
username = "{{.pg_user}}"
password = "{{.pg_password}}"
database = "{{.pg_database}}"
schema = "public"
{{end -}}
sslmode = "disable"
connection_max_idle = 100
connection_max_open = 100
connection_max_lifetime_seconds = 0
pgbouncer_compatible = false
# if insert/upsert failing, you can disable upsert or update query syntax to match your RDBMS syntax:
enableUpsert = true
upsertQuery = """
  INSERT INTO "%[1]s" (dirhash, name, directory, meta)
    VALUES($1, $2, $3, $4)
    ON CONFLICT (dirhash, name) DO UPDATE SET
      directory=EXCLUDED.directory,
      meta=EXCLUDED.meta
"""
EOF
      }
    }
  }
}
