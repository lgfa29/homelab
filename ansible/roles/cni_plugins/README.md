# `cni_plugins` Role

Role to download and install the [reference CNI
plugins](https://github.com/containernetworking/plugins).

## Defaults

| Name                  | Type     | Default                                                                                                                                                                                                                | Description                                                   |
| --------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `cni_plugins_path`    | `string` | `/opt/cni/bin`                                                                                                                                                                                                         | The path where the plugins will be placed in the target host. |
| `cni_plugins_url`     | `string` | `https://github.com/containernetworking/plugins/releases/download/v{{ cni_plugins_version }}/cni-plugins-{{ ansible_system | lower }}-{{ cni_plugins_arch_map[ansible_architecture] }}-v{{ cni_plugins_version }}.tgz` | The URL used to download the plugins.                         |
| `cni_plugins_version` | `string` | `1.1.1`                                                                                                                                                                                                                | The plugins version to install.                               |
