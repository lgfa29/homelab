resource "random_password" "traefik_admin" {
  length = 30
}

resource "random_password" "postgres_root" {
  length = 30
}

resource "random_password" "seaweedfs_filer_pg" {
  length = 30
}

resource "nomad_variable" "isponsorblocktv" {
  path      = "nomad/jobs/isponsorblocktv"
  namespace = "default"

  items = {
    device_id = local.secrets.isponsorblocktv.device_id
  }
}

resource "nomad_variable" "tailscale" {
  path      = "nomad/jobs/tailscale"
  namespace = "default"

  items = {
    auth_key = local.secrets.tailscale.auth_key
  }
}

resource "nomad_variable" "postgres" {
  path      = "nomad/jobs/postgres"
  namespace = "default"

  items = {
    root_password = random_password.postgres_root.result
  }
}

resource "nomad_variable" "seaweeds_filer" {
  path      = "nomad/jobs/seaweedfs-filer"
  namespace = "default"

  items = {
    pg_database = "seaweedfs_filer"
    pg_user     = "seaweedfs_filer"
    pg_password = random_password.seaweedfs_filer_pg.result
  }
}

resource "nomad_node_pool" "vila" {
  name = "vila"
}
