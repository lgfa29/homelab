job "tailscale" {
  node_pool = "storage"

  group "tailscale" {
    volume "tailscale" {
      type   = "host"
      source = "tailscale"
    }

    network {
      port "healthz" {}
    }

    service {
      provider = "nomad"
      name     = "tailscale-healthz"
      port     = "healthz"

      check {
        type     = "http"
        path     = "/healthz"
        timeout  = "1s"
        interval = "3s"
      }
    }

    task "tailscale" {
      driver = "docker"

      config {
        image   = "tailscale/tailscale:v1.74.1"
        ports   = ["healthz"]
        cap_add = ["NET_ADMIN", "SYS_MODULE"]
        volumes = [
          "/dev/net/tun:/dev/net/tun"
        ]
      }

      volume_mount {
        volume      = "tailscale"
        destination = "/var/lib/tailscale"
      }

      resources {
        cpu    = 300
        memory = 512
      }

      env {
        TS_ROUTES                = "192.168.0.0/24"
        TS_STATE_DIR             = "/var/lib/tailscale"
        TS_HOSTNAME              = "homelab-subnet"
        TS_HEALTHCHECK_ADDR_PORT = "0.0.0.0:${NOMAD_PORT_healthz}"
        TS_EXTRA_ARGS            = "--snat-subnet-routes=false"
      }

      template {
        data        = <<EOF
{{with nomadVar "nomad/jobs/tailscale" -}}
TS_AUTHKEY={{.auth_key}}
{{end -}}
EOF
        destination = "${NOMAD_SECRETS_DIR}/env"
        env         = true
      }
    }
  }
}
