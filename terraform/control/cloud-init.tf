locals {
  nodes = {
    cluster_client_1 = {
      "cluster-client-1.yaml" = {
        content_type = "cloud-config.yaml"
        content      = file("${path.module}/cloud-init/cluster-client-1.yaml")
      }
    }
  }
}

data "cloudinit_config" "config" {
  for_each = local.nodes

  gzip = false
  # base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = file("${path.module}/cloud-init/cloud-config.yaml")
  }

  dynamic "part" {
    for_each = each.value

    content {
      filename     = part.key
      content_type = part.value.content_type
      content      = part.value.content
    }
  }
}

output "cloudinit_config" {
  value = { for k, v in data.cloudinit_config.config : k => v.rendered }
}
