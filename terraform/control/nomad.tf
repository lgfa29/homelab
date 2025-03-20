resource "random_password" "traefik_admin" {
  length = 30
}

resource "nomad_variable" "traefik" {
  path      = "nomad/jobs/traefik"
  namespace = "default"

  items = {
    admin_password = bcrypt(random_password.traefik_admin.result)
  }
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

resource "nomad_node_pool" "storage" {
  name = "storage"
}
