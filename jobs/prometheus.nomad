job "prometheus" {
  datacenters = ["storage"]

  group "prometheus" {
    network {
      port "http" {}
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v2.40.3"
        args = [
          "-p", ""
        ]
      }
    }
  }
}
