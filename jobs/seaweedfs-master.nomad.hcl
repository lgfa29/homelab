job "seaweedfs-master" {
  group "seaweedfs-master" {
    network {
      port "http" {}
      port "grpc" {}
    }

    service {
      provider = "nomad"
      name     = "http-seaweedfs-master"
      port     = "http"
      tags     = [
        "traefik.enable=true",
        "traefik.http.routers.seaweedfs.rule=Host(`seaweedfs.feijuca.fun`)",
      ]

      check {
        type     = "http"
        path     = "/cluster/healthz"
        method   = "HEAD"
        timeout  = "1s"
        interval = "10s"
      }
    }

    service {
      provider = "nomad"
      name     = "grpc-seaweedfs-master"
      port     = "grpc"
      tags     = ["grpc"]

      check {
        type     = "tcp"
        timeout  = "1s"
        interval = "10s"
      }
    }

    task "seaweedfs-master" {
      driver = "docker"

      config {
        image = "chrislusf/seaweedfs:3.97"
        ports = ["http", "grpc"]
        args = [
          "master",
          "-mdir", "${NOMAD_TASK_DIR}/seaweedfs",
          "-ip", NOMAD_IP_http,
          "-ip.bind", "0.0.0.0",
          "-port", NOMAD_PORT_http,
          "-port.grpc", NOMAD_PORT_grpc,
          "-defaultReplication", "010",
        ]
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }
  }
}
