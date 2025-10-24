job "pgadmin" {
  group "pgadmin" {
    task "pgadmin" {
      driver = "docker"

      config {
        image = "dpage/pgadmin4:9.9.0"
      }
    }
  }
}
