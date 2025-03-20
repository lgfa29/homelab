job "iperf3" {
  datacenters = ["dc1"]
  type        = "system"

  group "iperf3" {
    network {
      port "server" {
        to = 5201
      }
    }

    service {
      provider = "nomad"
      name     = "iperf3"
      port     = "server"

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "10s"
      }
    }

    task "iperf3-server" {
      driver = "docker"

      config {
        image = "taoyou/iperf3-alpine:v3.11"
        args = [
          "--server",
          "--port",
          "${NOMAD_PORT_server}"
        ]
        ports = ["server"]
      }

      resources {
        cpu    = 20
        memory = 10
      }
    }
  }
}
