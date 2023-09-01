terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# AWS Transfer Family provides fully managed support for file transfers over SFTP, FTPS, and FTP for Amazon S3 and Amazon EFS.
resource "aws_transfer_server" "transfer_server" {
  endpoint_details       = var.endpoint_details
  endpoint_type          = var.endpoint_type
  domain                 = var.domain
  address_allocation_ids = var.address_allocation_ids
  security_group_ids     = var.security_group_ids
  subnet_ids             = var.subnet_ids
  vpc_id                 = var.vpc_id
  tags                   = var.tags
  force_destroy          = var.force_destroy
  hosted_zone_id         = var.hosted_zone_id
  identity_provider_type = var.identity_provider_type
  invocation_role        = var.invocation_role
  logging_role           = var.logging_role
  protocols              = var.protocols
  url                    = var.url
}

