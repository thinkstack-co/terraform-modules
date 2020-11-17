data "aws_workspaces_bundle" "customer_image" {
  bundle_id = var.bundle_id
}

resource "aws_workspaces_workspace" "aws_workspace" {
  directory_id = var.directory_id
  bundle_id    = data.aws_workspaces_bundle.customer_image.id
  user_name    = var.user_name

  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key          = "alias/aws/workspaces"

  workspace_properties {
    compute_type_name                           = var.compute_type
    user_volume_size_gib                        = var.user_volume_size
    root_volume_size_gib                        = var.root_volume_size
    running_mode                                = var.running_mode_type
    running_mode_auto_stop_timeout_in_minutes   = var.auto_stop_timeout
  }

  timeouts {
    create = "60m"
  }

  tags = {
    terraform   = true
    environment = prod
  }
}