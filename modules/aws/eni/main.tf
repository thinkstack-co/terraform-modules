terraform {
  required_version = ">= 0.14.0"
}

###############################
# ENI
###############################

resource "aws_network_interface" "eni" {
  description        = var.description
  private_ips        = var.private_ips
  private_ips_count  = var.private_ips_count
  security_groups    = var.security_groups
  source_dest_check  = var.source_dest_check
  subnet_id          = var.subnet_id
  tags               = var.tags

  attachment {
    device_index = var.device_index
    instance     = var.instance_id
  }
}
