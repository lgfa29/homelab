data "nomad_plugin" "seaweedfs" {
  plugin_id        = "seaweedfs"
  wait_for_healthy = true
}

resource "nomad_csi_volume" "tailscale" {
  lifecycle {
    prevent_destroy = true
  }

  plugin_id    = data.nomad_plugin.seaweedfs.plugin_id
  volume_id    = "tailscale"
  name         = "tailscale"
  capacity_min = "1GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume" "adguard-conf" {
  lifecycle {
    prevent_destroy = true
  }

  plugin_id    = data.nomad_plugin.seaweedfs.plugin_id
  volume_id    = "adguard-conf"
  name         = "adguard-conf"
  capacity_min = "1GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume" "adguard-work" {
  lifecycle {
    prevent_destroy = true
  }

  plugin_id    = data.nomad_plugin.seaweedfs.plugin_id
  volume_id    = "adguard-work"
  name         = "adguard-work"
  capacity_min = "5GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}
