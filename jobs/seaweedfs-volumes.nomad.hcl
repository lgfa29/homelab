job "seaweedfs-volumes" {
  group "seaweedfs-volumes" {
    count = 3

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    constraint {
      distinct_property = meta.rack
      value             = "2"
    }

    network {
      port "http" {}
      port "grpc" {}
    }

    service {
      provider = "nomad"
      name     = "seaweedfs-volumes"
      port     = "http"
      tags     = ["http"]

      check {
        type     = "http"
        path     = "/status"
        timeout  = "1s"
        interval = "10s"
      }
    }

    volume "seaweedfs" {
      type   = "host"
      source = "seaweedfs"
    }

    task "seaweedfs-volume" {
      driver = "docker"

      config {
        image = "chrislusf/seaweedfs:3.97"
        ports = ["http", "grpc"]
        args = [
          "volume",
          "-mserver", SEAWEEDFS_MASTER,
          "-dataCenter", "${node.datacenter}",
          "-rack", "${meta.rack}",
          "-dir", "/data/seaweedfs/volume",
          "-ip", NOMAD_IP_http,
          "-ip.bind", "0.0.0.0",
          "-port", NOMAD_PORT_http,
          "-port.grpc", NOMAD_PORT_grpc,
          "-publicUrl", NOMAD_HOST_ADDR_http,
        ]
      }

      resources {
        cpu    = 512
        memory = 2048
      }

      volume_mount {
        volume      = "seaweedfs"
        destination = "/data/seaweedfs/volume"
      }

      template {
        destination = "${NOMAD_TASK_DIR}/env"
        env         = true
        data        = <<EOF
{{- range $i, $s := nomadService "http-seaweedfs-master"}}
SEAWEEDFS_MASTER={{$s.Address}}:{{$s.Port}}.{{with nomadService "grpc-seaweedfs-master"}}{{with index . 0}}{{.Port}}{{end}}{{end}}
{{- end}}
EOF
      }
    }
  }
}
