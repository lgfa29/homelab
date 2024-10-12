resource "nomad_variable" "traefik" {
  path      = "nomad/jobs/traefik"
  namespace = "default"

  items = {
    consul_token   = local.secrets.traefik.consul_token
    consul_key     = base64encode(file("${path.module}/../../ansible/secrets/tls/consul/feijuca-cli-consul-0-key.pem"))
    consul_cert    = base64encode(file("${path.module}/../../ansible/secrets/tls/consul/feijuca-cli-consul-0.pem"))
    consul_ca_cert = base64encode(file("${path.module}/../../ansible/secrets/tls/consul/consul-agent-ca.pem"))
  }
}

resource "nomad_variable" "isponsorblocktv" {
  path      = "nomad/jobs/isponsorblocktv"
  namespace = "default"

  items = {
    device_id = local.secrets.isponsorblocktv.device_id
  }
}

resource "nomad_node_pool" "storage" {
  name = "storage"
}
