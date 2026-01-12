job "coredns" {
  constraint {
    attribute = attr.unique.hostname
    operator  = "set_contains_any"
    value     = "rk1-2,rk1-3,px-nomad-client-1"
  }

  group "coredns" {
    count = 3

    restart {
      attempts = 15
      delay    = "3s"
      mode     = "delay"
    }

    network {
      port "dns" {
        static = 53
      }

      port "health" {}
      port "metrics" {}
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

    service {
      provider = "nomad"
      name     = "coredns-metrics"
      port     = "metrics"
    }

    task "coredns" {
      driver = "docker"

      config {
        image = "coredns/coredns:1.13.1"
        args  = ["-conf", "${NOMAD_TASK_DIR}/Corefile"]
        ports = ["dns", "health", "metrics"]
      }

      resources {
        cpu    = 100
        memory = 64
      }

      template {
        destination   = "${NOMAD_TASK_DIR}/Corefile"
        data          = <<EOF
(default) {
  log
  errors
  loop
  prometheus 0.0.0.0:{{env "NOMAD_PORT_metrics"}}
}

. {
  health 0.0.0.0:{{env "NOMAD_PORT_health"}}
  import default

  forward . {{range nomadService "adguard"}}{{.Address}}:{{.Port}} {{else}}149.112.121.10 149.112.122.10{{end}}
}

feijuca.fun:{{env "NOMAD_PORT_dns"}} {
  import default

  file {{env "NOMAD_TASK_DIR"}}/feijuca.fun.db
}
EOF
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      template {
        destination   = "${NOMAD_TASK_DIR}/feijuca.fun.db"
        data          = <<EOF
$ORIGIN feijuca.fun.
@    IN  SOA  ns{{env "NOMAD_ALLOC_INDEX"}}.feijuca.fun. lgfa29.gmail.com. 2015082541 7200 3600 1209600 3600

ns{{env "NOMAD_ALLOC_INDEX"}}  IN  A    {{env "NOMAD_IP_dns"}}
{{- range nomadService "traefik"}}
*    IN  A    {{.Address}}
{{- end}}
EOF
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }
    }
  }
}
