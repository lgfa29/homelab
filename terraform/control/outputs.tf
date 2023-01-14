output "consul_acl_token_node" {
  value = consul_acl_token.node.id
}

output "consul_acl_token_nomad_server" {
  value = consul_acl_token.nomad_server.id
}

output "consul_acl_token_nomad_client" {
  value = consul_acl_token.nomad_client.id
}

output "consul_acl_token_traefik" {
  value = consul_acl_token.traefik.id
}
