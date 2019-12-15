terraform {
  required_version = ">= 0.12.0"
}

resource "aws_directory_service_directory" "connector" {
  alias       = var.alias
  description = var.description
  name        = var.name
  password    = var.password
  size        = var.size
  tags        = var.tags
  type        = var.type

  connect_settings {
    customer_dns_ips  = var.customer_dns_ips
    customer_username = var.customer_username
    subnet_ids        = var.subnet_ids
    vpc_id            = var.vpc_id
  }
}
