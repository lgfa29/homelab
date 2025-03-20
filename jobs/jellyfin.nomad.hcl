locals {
  jellyfin_image = "jellyfin/jellyfin:10.10.6"
}

job "jellyfin" {
  group "jellyfin" {
    network {
      mode = "host"

      port "http" {
        static = 8096
      }
    }

    service {
      provider = "nomad"
      name     = "jellyfin"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.jellyfin.rule=Host(`jellyfin.feijuca.fun`)",
      ]
    }

    volume "jellyfin" {
      type   = "host"
      source = "jellyfin"
    }

    task "jellyfin" {
      driver = "docker"

      config {
        image        = local.jellyfin_image
        ports        = ["http"]
        network_mode = "host"

        args = [
          "--datadir", "${NOMAD_TASK_DIR}/jellyfin/data",
          "--cachedir", "${NOMAD_TASK_DIR}/jellyfin/cache",
        ]

        devices = [
          { host_path = "/dev/dri" },
          { host_path = "/dev/dma_heap" },
          { host_path = "/dev/mali0" },
          { host_path = "/dev/rga" },
          { host_path = "/dev/mpp_service" },
        ]
      }

      resources {
        cpu    = 4000
        memory = 4096
      }

      volume_mount {
        volume      = "jellyfin"
        destination = "${NOMAD_TASK_DIR}/jellyfin"
      }
    }
  }
}
