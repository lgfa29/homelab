job "home-assistant" {
  node_pool = "storage"

  group "home-assistant" {
    network {
      mode = "host"
      port "http" {
        to = 8123
      }
    }

    volume "home-assistant" {
      type   = "host"
      source = "home-assistant"
    }

    task "home-assistant" {
      driver = "docker"

      config {
        image        = "ghcr.io/home-assistant/home-assistant:2024.6.1"
        privileged   = true
        network_mode = "host"
        ports        = ["http"]
      }

      volume_mount {
        volume      = "home-assistant"
        destination = "/config"
      }
    }
  }
}
