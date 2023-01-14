job "pihole" {
  datacenters = ["dc1"]

  group "pihole" {
    restart {
      attempts = 15
      delay    = "3s"
    }

    network {
      port "dns" {
        to = 53
      }

      port "http" {
        to = 80
      }
    }

    service {
      name        = "pihole"
      port        = "dns"
      tags        = ["dns"]
      canary_tags = ["canary"]
    }

    service {
      name = "pihole-ui"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.pihole.rule=Host(`pihole.feijuca.fun`)",
        "traefik.http.routers.pihole.middlewares=piholeAdmin",
        "traefik.http.middlewares.piholeAdmin.addPrefix.prefix=/admin",
      ]
      canary_tags = ["canary"]

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "5s"
      }
    }

    task "pihole" {
      driver = "docker"

      config {
        image = "pihole/pihole:2022.10"
        ports = ["dns", "http"]
      }

      env {
        TZ                = "America/Toronto"
        WEBPASSWORD_FILE  = "${NOMAD_SECRETS_DIR}/webpassword"
        DNSMASQ_LISTENING = "all"
      }

      resources {
        cpu    = 50
        memory = 256
      }

      template {
        data = <<EOF
{{with nomadVar "nomad/jobs/pihole"}}{{.webpassword}}{{end}}
EOF

        destination = "${NOMAD_SECRETS_DIR}/webpassword"
        change_mode = "noop"
      }
    }
  }
}
