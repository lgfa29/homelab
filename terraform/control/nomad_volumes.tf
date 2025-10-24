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
