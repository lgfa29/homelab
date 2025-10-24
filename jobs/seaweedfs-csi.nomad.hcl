job "seaweedfs-csi" {
  type = "system"

  update {
    max_parallel = 1
    stagger      = "60s"
  }

  group "seaweedfs-csi" {
    task "seaweedfs-csi" {
      driver = "docker"

      config {
        image = "chrislusf/seaweedfs-csi-driver:v1.2.7"
        args = [
          "--endpoint=unix://csi/csi.sock",
          "--filer=${SEAWEEDFS_FILER_ADDR}",
          "--nodeid=${node.unique.name}",
          "--cacheCapacityMB=256",
          "--cacheDir=${NOMAD_TASK_DIR}/cache_dir",
        ]
        privileged = true
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env"
        env         = true
        data        = <<EOF
{{range nomadService 1 (env "NOMAD_ALLOC_ID") "seaweedfs-filer-grpc" -}}
SEAWEEDFS_FILER_ADDR={{.Address}}:{{.Port | subtract 10000}}
{{end -}}
EOF
      }

      csi_plugin {
        id        = "seaweedfs"
        type      = "monolith"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 512
        memory = 1024
      }
    }
  }
}
