job "traefik" {
  datacenters = ["dc1"]

  group "traefik" {
    count = 2

    network {
      port "http" {
        static = 80
      }

      port "https" {
        static = 443
      }

      port "admin" {
        static = 8080
      }
    }

    service {
      name = "traefik"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.api.rule=Host(`traefik.feijuca.fun`)",
        "traefik.http.routers.api.service=api@internal",
      ]

      check {
        type = "http"
        path = "/ping"

        timeout  = "1s"
        interval = "5s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v2.9.4"
        args = [
          "--configfile",
          "${NOMAD_SECRETS_DIR}/traefik.toml",
        ]
        ports = ["admin", "http", "https"]
      }

      template {
        data        = <<EOF
[api]
  dashboard = true
  insecure = true
  debug = true

[ping]
  entryPoint = "http"

[log]
  level = "DEBUG"

[accessLog]

[entryPoints]
  [entryPoints.http]
    address = ":{{env "NOMAD_PORT_http"}}"
  [entryPoints.https]
    address = ":{{env "NOMAD_PORT_https"}}"
  [entryPoints.traefik]
    address = ":{{env "NOMAD_PORT_admin"}}"

[providers]
  [providers.consulCatalog]
    exposedByDefault = false
    [providers.consulCatalog.endpoint]
      address = "{{env "attr.unique.network.ip-address"}}:8501"
      scheme = "https"
      token = "{{with nomadVar "nomad/jobs/traefik"}}{{.consul_token}}{{end}}"
      [providers.consulCatalog.endpoint.tls]
        ca = "{{env "NOMAD_SECRETS_DIR"}}/consul-ca.pem"
        cert = "{{env "NOMAD_SECRETS_DIR"}}/consul-cert.pem"
        key = "{{env "NOMAD_SECRETS_DIR"}}/consul-key.pem"
        insecureSkipVerify = true

[tls.options]
  [tls.options.nomad]
    [tls.options.nomad.clientAuth]
      caFiles = []
EOF
        destination = "${NOMAD_SECRETS_DIR}/traefik.toml"
      }

      template {
        data        = <<EOF
{{with nomadVar "nomad/jobs/traefik"}}{{.consul_ca_cert.Value | base64Decode}}{{end}}
EOF
        destination = "${NOMAD_SECRETS_DIR}/consul-ca.pem"
      }

      template {
        data        = <<EOF
{{with nomadVar "nomad/jobs/traefik"}}{{.consul_cert.Value | base64Decode}}{{end}}
EOF
        destination = "${NOMAD_SECRETS_DIR}/consul-cert.pem"
      }

      template {
        data        = <<EOF
{{with nomadVar "nomad/jobs/traefik"}}{{.consul_key.Value | base64Decode}}{{end}}
EOF
        destination = "${NOMAD_SECRETS_DIR}/consul-key.pem"
      }
    }
  }
}
