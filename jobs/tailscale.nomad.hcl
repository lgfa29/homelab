job "tailscale" {
  group "tailscale" {
    restart {
      attempts = 15
      delay    = "3s"
      mode     = "delay"
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

    volume "tailscale" {
      type            = "csi"
      source          = "tailscale"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "tailscale" {
      driver = "docker"

      config {
        image   = "tailscale/tailscale:v1.88.4"
        ports   = ["healthz"]
        cap_add = ["NET_ADMIN", "SYS_MODULE"]
        volumes = [
          "/dev/net/tun:/dev/net/tun"
        ]
      }

      env {
        TS_ROUTES                = "192.168.1.0/24"
        TS_STATE_DIR             = "/var/lib/tailscale"
        TS_HOSTNAME              = "homelab-subnet"
        TS_HEALTHCHECK_ADDR_PORT = "0.0.0.0:${NOMAD_PORT_healthz}"
        TS_EXTRA_ARGS            = "--snat-subnet-routes=false"
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env"
        env         = true
        data        = <<EOF
{{with nomadVar "nomad/jobs/tailscale" -}}
TS_AUTHKEY={{.auth_key}}
{{end -}}
EOF
      }

      resources {
        cpu    = 300
        memory = 512
      }

      volume_mount {
        volume      = "tailscale"
        destination = "/var/lib/tailscale"
      }
    }
  }
}
