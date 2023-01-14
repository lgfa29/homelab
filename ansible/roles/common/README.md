# `common` Role

Role to execute basic actions that are common to several machines and
scenarios. The tasks performed are:

- Install common APT packages.
- Disable the default Ubuntu motd.news.

## Defaults

| Name                  | Type           | Default | Description                                           |
| --------------------- | -------------- | ------- | ----------------------------------------------------- |
| `common_apt_packages` | `list(string)` | `[]`    | A list of APT packages to install in the target host. |
