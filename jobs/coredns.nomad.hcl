job "coredns" {
  constraint {
    attribute = attr.unique.hostname
    operator  = "set_contains_any"
    value     = "rk1-3,rk1-4"
  }

  group "coredns" {
    count = 2

    restart {
      attempts = 15
      delay    = "3s"
    }

    network {
      port "dns" {
        static = 53
      }

      port "health" {}
    }

    service {
      provider = "nomad"
      name     = "coredns"
      port     = "dns"

      check {
        type = "http"
        path = "/health"
        port = "health"

        timeout  = "1s"
        interval = "5s"
      }
    }

    task "coredns" {
      driver = "docker"

      config {
        image = "coredns/coredns:1.10.0"
        args  = ["-conf", "${NOMAD_TASK_DIR}/Corefile"]
        ports = ["dns", "health"]
      }

      resources {
        cpu    = 20
        memory = 50
      }

      template {
        destination   = "${NOMAD_TASK_DIR}/Corefile"
        data          = <<EOF
. {
  log
  errors
  loop
  health 0.0.0.0:{{env "NOMAD_PORT_health"}}

  file {{env "NOMAD_TASK_DIR"}}/cluster.db feijuca.fun
  {{- with nomadService "dns.adguard"}}
  forward . {{range .}}{{.Address}}:{{.Port}} {{end}}
  {{- end}}
}
EOF
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      template {
        destination   = "${NOMAD_TASK_DIR}/cluster.db"
        data          = <<EOF
feijuca.fun.      IN      SOA     ns.dns.cluster.feijuca. hostmaster.cluster.feijuca. 2015082541 7200 3600 1209600 3600
{{- range nomadService "traefik"}}
*.feijuca.fun.    IN      A       {{.Address}}
{{- end}}
EOF
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }
    }
  }
}
