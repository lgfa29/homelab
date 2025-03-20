locals {
  traefik_image = "traefik:v3.3.3"
}

job "traefik" {
  datacenters = ["dc1"]

  group "traefik" {
    count = 3

    network {
      port "http" {
        static = 80
      }

      port "https" {
        static = 443
      }
    }

    service {
      provider = "nomad"
      name     = "traefik"
      port     = "http"

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
        image = local.traefik_image
        args  = ["--configfile", "${NOMAD_SECRETS_DIR}/traefik.yaml"]
        ports = ["http", "https"]
      }

      identity {
        env = true
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/traefik.yaml"
        data        = <<EOF
api:
  dashboard: true
ping:
  entryPoint: "http"
log:
  level: "INFO"
accessLog: {}
entryPoints:
  http:
    address: ":{{env "NOMAD_PORT_http"}}"
    #http:
    #  redirections:
    #    entryPoint:
    #      to: "https"
    #      scheme: "https"
    #      permanent: true
  https:
    address: ":{{env "NOMAD_PORT_https"}}"
providers:
  file:
    watch: true
    directory: "{{env "NOMAD_SECRETS_DIR"}}/config"
  nomad:
    exposedByDefault: false
    endpoint:
      address: "https://{{ env "attr.unique.network.ip-address"}}:4646"
      token: "{{env "NOMAD_TOKEN"}}"
      tls:
        insecureSkipVerify: true
EOF
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/config/routes.yaml"
        change_mode = "noop"
        data        = <<EOF
http:
  routers:
    dashboard:
      rule: "Host(`traefik.feijuca.fun`)"
      service: "api@internal"
      middlewares:
        - "auth"
    turingpi:
      rule: "Host(`turingpi.feijuca.fun`)"
      service: "turingpi"
    nomad:
      rule: "Host(`nomad.feijuca.fun`)"
      service: "nomad"
  middlewares:
    auth:
      basicAuth:
        users:
          - "admin:{{with nomadVar "nomad/jobs/traefik"}}{{.admin_password.Value}}{{end}}"
  services:
    turingpi:
      loadBalancer:
        serversTransport: "tlsInsecure"
        servers:
          - url: "https://192.168.0.30"
    nomad:
      loadBalancer:
        serversTransport: "tlsInsecure"
        servers:
          - url: "https://192.168.0.50:4646"
  serversTransports:
    tlsInsecure:
      insecureSkipVerify: true
EOF
      }
    }
  }
}
