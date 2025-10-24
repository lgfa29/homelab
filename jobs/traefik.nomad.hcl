locals {
  traefik_image = "traefik:v3.5.3"
}

job "traefik" {
  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 80
      }

      port "https" {
        static = 443
      }

      port "pg" {
        static = 5432
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
        ports = ["http", "https", "pg"]
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
  pg:
    address: ":{{env "NOMAD_PORT_pg"}}"
providers:
  file:
    watch: true
    directory: "{{env "NOMAD_SECRETS_DIR"}}/config"
  nomad:
    exposedByDefault: false
    endpoint:
      address: "unix:///{{env "NOMAD_SECRETS_DIR"}}/api.sock"
EOF
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/config/routes.yaml"
        change_mode = "noop"
        data        = <<EOF
        #tcp:
        #  routers:
        #    pg:
        #      entryPoints:
        #        - "pg"
http:
  routers:
    dashboard:
      rule: "Host(`traefik.feijuca.fun`)"
      entryPoints:
        - "http"
      service: "api@internal"
      #middlewares:
      #  - "auth"
    turingpi:
      rule: "Host(`turingpi.feijuca.fun`)"
      entryPoints:
        - "http"
      service: "turingpi"
    nomad:
      rule: "Host(`nomad.feijuca.fun`)"
      entryPoints:
        - "http"
      service: "nomad"
  services:
    turingpi:
      loadBalancer:
        serversTransport: "tlsInsecure"
        servers:
          - url: "https://192.168.1.30"
    nomad:
      loadBalancer:
        servers:
          - url: "http://192.168.1.31:4646"
  serversTransports:
    tlsInsecure:
      insecureSkipVerify: true
EOF
      }
    }
  }
}
