# `consul` Role

Installs and configures [HashiCorp Consul](https://www.consul.io/).

## Defaults

| Name                             | Type                                   | Default       | Description                                                                                                                                                                                            |
| -------------------------------- | -------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `consul_version`                 | `string`                               | `""`          | Version of Consul to install.                                                                                                                                                                          |
| `consul_pkg_version`             | `string`                               | `"1"`         | Version of the Consul Linux package to install.                                                                                                                                                        |
| `consul_user`                    | `string`                               | `"consul"`    | Operating system user to run the Consul agent.                                                                                                                                                         |
| `consul_group`                   | `string`                               | `"consul"`    | Operating system user group to run the Consul agent.                                                                                                                                                   |
| `consul_node_name`               | `string`                               | `""`          | The name of this node in the cluster. Equivalent to the [`node_name`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#node_name) Consul configuration.                           |
| `consul_datacenter`              | `string`                               | `"dc1"`       | Consul datacenter this agent is running. Equivalent to the [`datacenter`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#datacenter) Consul configuration.                      |
| `consul_client_addr`             | `string`                               | `"127.0.0.1"` | Address used by Consul to bind client interfaces. Equivalent to the [`client_addr`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#client_addr) Consul configuration.           |
| `consul_bind_addr`               | `string`                               | `"0.0.0.0"`   | Address used by Consul to bind internal interfaces. Equivalent to the [`bind_addr`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#bind_addr) Consul configuration.             |
| `consul_retry_join`              | `list(string)`                         | `[]`          | List of strings used to find other Consul agents. Equivalent to the [`retry_join`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#retry_join) Consul configuration.             |
| `consul_encrypt_key`             | `string`                               | `""`          | Secret key used to encrypt Consul network traffic. Equivalent to the [`encrypt`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#encrypt) Consul configuration.                  |
| `consul_server_enabled`          | `bool`                                 | `false`       | If `true` the agent runs in server mode. Equivalent to the [`server`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#server-1) Consul configuration.                            |
| `consul_server_bootstrap_expect` | `integer`                              | `1`           | The number of servers expected in the datacenter. Equivalent to the [`bootstrap_expect`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#bootstrap_expect) Consul configuration. |
| `consul_acl_enabled`             | `bool`                                 | `true`        | If `true` the ACL system is enabled. Equivalent to the [`acl.enabled`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#acl_enabled) Consul configuration.                        |
| `consul_acl_tokens`              | `map(string: string)`                  | `{}`          | Map of ACL tokens to be used by the agent. Equivalent to the [`acl.tokens`](https://developer.hashicorp.com/consul/docs/agent/config/config-files#acl_tokens) Consul configuration.                    |
| `consul_tls_enabled`             | `bool`                                 | `true`        | If `true` enables HTTPS on port `8501` and verification for incoming and outgoing traffic.                                                                                                             |
| `consul_tls_ca_cert`             | `string`                               | `""`          | Contents of the CA certificate used for mTLS.                                                                                                                                                          |
| `consul_tls_cert`                | `string`                               | `""`          | Contents of the mTLS certificate used by the Consul agent.                                                                                                                                             |
| `consul_tls_key`                 | `string`                               | `""`          | Contents of the mTLS certificate key used by the Consul agent.                                                                                                                                         |
| `consul_extra_config_files`      | `list(map(src: string, dest: string))` | `{}`          | Additional templates that are rendered as Consul configuration files.                                                                                                                                  |