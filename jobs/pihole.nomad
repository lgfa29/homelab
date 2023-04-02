locals {
  pihole_image = "pihole/pihole:2023.03.1"
}

job "pihole" {
  datacenters = ["storage"]

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
      ]
      canary_tags = ["canary"]

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "5s"
      }
    }

    volume "pihole" {
      type   = "host"
      source = "pihole"
    }

    task "pihole" {
      driver = "docker"

      config {
        image = local.pihole_image
        ports = ["dns", "http"]
      }

      env {
        TZ                   = "America/Toronto"
        WEBPASSWORD_FILE     = "${NOMAD_SECRETS_DIR}/webpassword"
        DNSMASQ_LISTENING    = "all"
        FTLCONF_PRIVACYLEVEL = "0"
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

      volume_mount {
        volume      = "pihole"
        destination = "/etc/pihole"
      }
    }
  }
}
