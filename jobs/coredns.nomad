job "coredns" {
  type        = "system"
  datacenters = ["dc1"]

  group "coredns" {
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
      name = "coredns"
      port = "dns"

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
        args = [
          "-conf",
          "${NOMAD_TASK_DIR}/Corefile",
        ]
        ports = ["dns", "health"]
      }

      resources {
        cpu    = 20
        memory = 50
      }

      template {
        data          = <<EOF
. {
  log
  errors
  loop
  health 0.0.0.0:{{env "NOMAD_PORT_health"}}

  file {{env "NOMAD_TASK_DIR"}}/cluster.db feijuca.fun
  forward consul {{env "attr.unique.network.ip-address"}}:8600
  {{- with service "dns.pihole"}}
  forward . {{range .}}{{.Address}}:{{.Port}} {{end}}
  {{- end}}
}
EOF
        destination   = "${NOMAD_TASK_DIR}/Corefile"
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      template {
        data          = <<EOF
feijuca.fun.      IN      SOA     ns.dns.cluster.feijuca. hostmaster.cluster.feijuca. 2015082541 7200 3600 1209600 3600
{{- range service "nomad-client"}}
nomad.feijuca.fun.  IN  A   {{.Address}}
{{- end}}
{{- range service "traefik"}}
*.feijuca.fun.    IN      A       {{.Address}}
{{- end}}
EOF
        destination   = "${NOMAD_TASK_DIR}/cluster.db"
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }
    }
  }
}
