# Node ACL
resource "consul_acl_policy" "node" {
  name  = "node-policy"
  rules = <<EOF
agent_prefix "" {
  policy = "write"
}

node_prefix "" {
  policy = "write"
}

service_prefix "" {
  policy = "read"
}

session_prefix "" {
  policy = "read"
}
EOF
}

resource "consul_acl_token" "node" {
  description = "node token"
  policies = [
    consul_acl_policy.node.name,
  ]
}

# DNS ACL
resource "consul_acl_policy" "dns" {
  name  = "dns"
  rules = <<EOF
node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "read"
}
EOF
}

resource "consul_acl_token_policy_attachment" "anonymous_dns" {
  token_id = "00000000-0000-0000-0000-000000000002"
  policy   = consul_acl_policy.dns.name
}

# Nomad ACL
resource "consul_acl_policy" "nomad_server" {
  name        = "nomad-server"
  description = "Nomad server policy"
  rules       = <<EOF
agent_prefix "" {
  policy = "read"
}

node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "write"
}

acl = "write"
operator = "write"
EOF
}

resource "consul_acl_token" "nomad_server" {
  description = "Nomad server token"
  policies = [
    consul_acl_policy.nomad_server.name,
  ]
}

resource "consul_acl_policy" "nomad_client" {
  name        = "nomad-client"
  description = "Nomad client policy"
  rules       = <<EOF
agent_prefix "" {
  policy = "read"
}

node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "write"
}

key_prefix "" {
  policy = "read"
}
EOF
}

resource "consul_acl_token" "nomad_client" {
  description = "Nomad client token"
  policies = [
    consul_acl_policy.nomad_client.name,
  ]
}

# Traefik
resource "consul_acl_policy" "traefik" {
  name        = "traefik"
  description = "Token for Traefik service"
  rules       = <<EOF
service_prefix "" {
  policy = "read"
}

node_prefix ""{
  policy = "read"
}
EOF
}

resource "consul_acl_token" "traefik" {
  description = "Traefik token"
  policies = [
    consul_acl_policy.traefik.name,
  ]
}
