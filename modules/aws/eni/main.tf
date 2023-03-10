terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###############################
# ENI
###############################

resource "aws_network_interface" "eni" {

  private_ips             = var.private_ips
  private_ips_count       = var.private_ips_count
  private_ip_list_enabled = var.private_ip_list_enabled
  security_groups         = var.security_groups
  source_dest_check       = var.source_dest_check
  subnet_id               = var.subnet_id
  tags                    = var.tags
  attachment {
    device_index = var.device_index
    instance     = var.instance_id
  }
}
