job "iperf3" {
  type = "system"

  group "iperf3" {
    network {
      port "server" {
        static = 5201
      }
    }

    service {
      provider = "nomad"
      name     = "iperf3"
      port     = "server"
    }

    task "iperf3-server" {
      driver = "docker"

      config {
        image = "networkstatic/iperf3@sha256:07dcca91c0e47d82d83d91de8c3d46b840eef4180499456b4fa8d6dadb46b6c8"
        args = [
          "--server",
          "--port",
          "${NOMAD_PORT_server}",
        ]
        ports = ["server"]
      }

      resources {
        cpu    = 100
        memory = 10
      }
    }
  }
}
